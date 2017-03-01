class WikipediaSource < Source
  class WikiParser < WikiCloth::Parser
    url_for do |page|
      "https://en.wikipedia.org/wiki/#{page}"
    end
  end

  def initialize
    @title = 'Wikipedia'
    @url = 'https://en.wikipedia.org/'
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
      time = (Time.now - i * 86400).strftime('%Y_%B_%d')
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
      sort_by { |item| -item['pageid'] }

    items.map do |item|
      created_at = nil
      text = nil
      html = nil
      item['revisions'].each do |revision|
        created_at = Time.parse(revision['timestamp'])
        text = revision['*'].
          gsub("\n<!-- All news items above this line -->|}", '')
        html = WikiParser.new(:data => text).to_html
      end

      Item.new(
        created_at: created_at,
        title: item['title'],
        via: item['fullurl'],
        url: item['fullurl'],
        text: text,
        html: html
      )
    end
  end
end
