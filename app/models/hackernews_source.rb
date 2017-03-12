class HackernewsSource < Source
  def initialize
    @title = 'Hacker News'
    @url = 'https://news.ycombinator.com'
  end

  def request(args, options={})
    api = (args.size > 1 || options.include?(:time)) ? :request_search : :request_homepage

    items = send(api, args, options)

    items.map do |item|
      HackernewsItem.from_hash(item)
    end
  end

  # https://github.com/cheeaun/node-hnapi/wiki/API-Documentation
  def request_homepage(args, options={})
    limit = (1..30).include?(options[:limit]) ? options[:limit] : 30

    sorts = %i(new hot top)
    sort = sorts.include?(options[:sort]) ? options[:sort] : :hot

    url = 'http://node-hnapi.herokuapp.com/news'
    res = RestClient.get(url)
    items = JSON.parse(res.body)
    items = items.sort_by { |item| -(item['points'] || 0) } if sort == :top
    items = items.sort_by { |item| -item['time'] } if sort == :new

    items.take(limit)
  end

  # https://hn.algolia.com/api
  def request_search(args, options={})
    limit = (1..100).include?(options[:limit]) ? options[:limit] : 10

    # NOTE: only used by top and controversial sorts
    times = %i(hour day week month year all)
    opt = options[:t] || options[:time]
    time = times.include?(opt) ? opt : :day
    created_after = time == :all ? 0 : (Time.zone.now - 1.send(time)).to_i

    params = {
      query: args[1..-1].join(' '),
      tags: 'story',
      hitsPerPage: limit,
      numericFilters: "created_at_i>#{created_after}"
    }

    url = 'http://hn.algolia.com/api/v1/search'
    res = RestClient.get(url, params: params)
    json = JSON.parse(res.body)

    json['hits']
  end
end
