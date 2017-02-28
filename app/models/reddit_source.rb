class RedditSource < Source
  def initialize
    @title = 'Reddit'
    @url = 'https://www.reddit.com'
  end

  # https://www.reddit.com/dev/api
  def request(args, options={})
    params = {}

    params[:limit] = (1..100).include?(options[:limit]) ? options[:limit] : 25

    # NOTE: only used by top and controversial sorts
    times = %i(hour day week month year all)
    opt = options[:t] || options[:time]
    params[:t] = times.include?(opt) ? opt : :day

    sorts = %i(new hot top rising controversial)
    sort = sorts.include?(options[:sort]) ? options[:sort] : :hot

    subreddits = args[1..-1].join('+')
    url = "https://www.reddit.com/r/#{subreddits}/#{sort}.json"
    res = RestClient.get(url, :params => params)
    json = JSON.parse(res.body)
    items = json['data']['children']

    items.map do |item|
      image = nil
      (item.dig('data', 'preview', 'images') || []).each do |img|
        width = 0
        img['resolutions'].each do |resolution|
          if width < resolution['width']
            width = resolution['width']
            image = resolution['url']
          end
        end
      end

      Item.new(
        created_at: Time.at(item['data']['created_utc'].to_i),
        title: item['data']['title'],
        url: item['data']['url'],
        via: "https://www.reddit.com#{item['data']['permalink']}",
        image: image.gsub('&amp;', '&'),
        counts: Counts.new(
          score: item['data']['score'],
          comments: item['data']['num_comments']
        )
      )
    end
  rescue RestClient::NotFound
  end
end
