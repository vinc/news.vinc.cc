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
      RedditItem.from_hash(item)
    end
  rescue RestClient::NotFound
  end
end
