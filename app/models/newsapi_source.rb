class NewsapiSource < Source
  def initialize
    @title = 'News API'
    @url = 'https://newsapi.org/'

    @source_title = @title
    @source_url = @url
    @filters = {
      sorts: %i(new hot top),
      limits: 1..50
    }
  end

  # https://newsapi.org/
  def request(args, options={})
    limit = @filters[:limits].include?(options[:limit]) ? options[:limit] : 10

    sorts = {
      :new => :latest,
      :hot => :popular,
      :top => :top
    }
    sort = sorts[options[:sort]] || :top

    params = {
      source: args[1],
      sortBy: sort,
      apiKey: ENV['NEWSAPI_KEY']
    }
    url = 'https://newsapi.org/v1/articles'
    res = RestClient.get(url, :params => params)
    json = JSON.parse(res.body)
    items = json['articles'].take(limit)

    items.map do |item|
      NewsapiItem.from_hash(item)
    end
  rescue RestClient::NotFound
  end

  def get_suggestions(query)
    # Only one source per query
    return [] if query.split(' ', -1).keep_if { |w| !w[':']}.count > 2

    Rails.cache.fetch('newsapi:suggestions', expires_in: 1.day) do
      url = 'https://newsapi.org/v1/sources'
      res = RestClient.get(url)
      json = JSON.parse(res.body)
      json['sources'].map { |source| source['id'] }
    end
  end
end
