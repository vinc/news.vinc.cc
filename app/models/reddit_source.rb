class RedditSource < Source
  def initialize
    @title = 'Reddit'
    @url = 'https://www.reddit.com'
    @filters = {
      sorts: %i(new hot top rising controversial),
      times: %i(hour day week month year all),
      limits: 1..100
    }
  end

  # https://www.reddit.com/dev/api
  def request(args, options={})
    params = {}

    params[:limit] = @filters[:limits].include?(options[:limit]) ? options[:limit] : 25

    # NOTE: only used by top and controversial sorts
    opt = options[:t] || options[:time]
    params[:t] = @filters[:times].include?(opt) ? opt : :day

    sort = @filters[:sorts].include?(options[:sort]) ? options[:sort] : :hot

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

  def get_suggestions(query)
    Rails.cache.fetch('reddit:suggestions', expires_in: 1.day) do
      url = 'https://www.reddit.com/subreddits/popular.json'
      subreddits = []
      after = nil

      5.times do
        params = { limit: 100, count: subreddits.size, after: after }
        res = RestClient.get(url, params: params)
        json = JSON.parse(res.body)
        after = json['data']['after']
        json['data']['children'].each do |child|
          subreddits << child['data']['display_name'].downcase
        end
      end

      subreddits
    end
  end
end
