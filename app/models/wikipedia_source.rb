class WikipediaSource < Source
  def initialize
    @title = 'Wikipedia'
    @url = 'https://en.wikipedia.org/'
    @filters = {
      times: %i(day week),
      limits: 1..10
    }
  end

  # https://www.mediawiki.org/wiki/API:Query
  def request(args, options={})
    limit =
      case options[:limit] || options[:t] || options[:time]
      when 1..10 then options[:limit]
      when :week then 7
      when :day then 1
      else 3
      end

    titles = limit.times.map do |i|
      time = (Time.now - i * 86400).strftime('%Y_%B_%-d')
      "Portal:Current_events/#{time}"
    end

    url = 'https://en.wikipedia.org/w/api.php'
    params = {
      prop:   'info|revisions',
      rvprop: 'timestamp|content',
      format: 'json',
      action: 'query',
      inprop: 'url',
      titles: titles.join('|')
    }
    res = RestClient.get(url, params: params)
    json = JSON.parse(res.body)
    items = json['query']['pages'].
      map { |k, v| v }.
      delete_if { |item| item['pageid'].nil? }.
      sort_by { |item| -Time.parse(item['fullurl'].split('/').last).to_i }

    items.map do |item|
      WikipediaItem.from_hash(item)
    end
  end

  def get_suggestions(query)
    ['events']
  end
end
