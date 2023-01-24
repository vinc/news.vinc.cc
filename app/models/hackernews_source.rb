class HackernewsSource < Source
  def initialize
    @title = "Hacker News"
    @url = "https://news.ycombinator.com"
  end

  def initialize_homepage
    @source_title = "HNapi"
    @source_url = "https://github.com/cheeaun/node-hnapi"
    @source_api = :request_homepage
    @filters = {
      sorts: %i[new hot top],
      limits: 1..30
    }
  end

  def initialize_search
    @source_title = "Algolia"
    @source_url = "https://hn.algolia.com"
    @source_api = :request_search
    @filters = {
      times: %i[hour day week month year all],
      limits: 1..100
    }
  end

  def before_search(query)
    f = "time:"
    if query.split.keep_if { |w| !w[":"] || w.starts_with?(f) }.count > 1
      initialize_search
    else
      initialize_homepage
    end
  end

  def before_autocomplete(query)
    words = query.split(" ", -1)
    w = words.pop
    f = "time:"
    if w.starts_with?(f) || f.starts_with?(w)
      before_search(query)
    else
      before_search(words.join(" "))
    end
  end

  def request(args, options = {})
    items = send(@source_api, args, options)

    items.map do |item|
      HackernewsItem.from_hash(item)
    end
  end

  # https://github.com/cheeaun/node-hnapi/wiki/API-Documentation
  def request_homepage(_args, options = {})
    limit = @filters[:limits].include?(options[:limit]) ? options[:limit] : 30
    sort = @filters[:sorts].include?(options[:sort]) ? options[:sort] : :hot

    url = "https://api.hackerwebapp.com/news"
    res = RestClient.get(url)
    items = JSON.parse(res.body)
    items = items.sort_by { |item| -(item["points"] || 0) } if sort == :top
    items = items.sort_by { |item| -item["time"] } if sort == :new

    items.take(limit)
  end

  # https://hn.algolia.com/api
  def request_search(args, options = {})
    limit = @filters[:limits].include?(options[:limit]) ? options[:limit] : 10
    time = @filters[:times].include?(options[:time]) ? options[:time] : :day

    created_after = time == :all ? 0 : (Time.zone.now - 1.send(time)).to_i

    params = {
      query: args[1..-1].join(" "),
      tags: "story",
      hitsPerPage: limit,
      numericFilters: "created_at_i>#{created_after}"
    }

    url = "https://hn.algolia.com/api/v1/search"
    res = RestClient.get(url, params: params)
    json = JSON.parse(res.body)

    json["hits"]
  end
end
