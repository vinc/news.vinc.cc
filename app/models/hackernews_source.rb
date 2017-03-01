class HackernewsSource < Source
  def initialize
    @title = 'Hacker News'
    @url = 'https://news.ycombinator.com'
  end

  # https://github.com/cheeaun/node-hnapi/wiki/API-Documentation
  def request(args, options={})
    limit = (1..30).include?(options[:limit]) ? options[:limit] : 30

    sorts = %i(new hot top)
    sort = sorts.include?(options[:sort]) ? options[:sort] : :hot

    url = 'http://node-hnapi.herokuapp.com/news'
    res = RestClient.get(url)
    items = JSON.parse(res.body)
    items = items.sort_by { |item| -(item['points'] || 0) } if sort == :top
    items = items.sort_by { |item| -item['time'] } if sort == :new
    items = items.take(limit)

    items.map do |item|
      HackernewsItem.from_hash(item)
    end
  end
end
