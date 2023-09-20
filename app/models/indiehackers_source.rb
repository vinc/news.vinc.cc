# frozen_string_literal: true

class IndiehackersSource < Source
  def initialize
    @title = "Indie Hackers"
    @url = "https://www.indiehackers.com/"
    @source_title = "Indie Hackers RSS"
    @source_url = "https://github.com/ahonn/ihrss"
    @filters = {
      times: %i[day week month all]
    }
  end

  def time_param(time)
    case time
      when :week then "week"
      when :month then "month"
      when :all then "all-time"
      else "today"
    end
  end

  def request(args, options = {})
    time = time_param(options[:t] || options[:time])
    url = "https://ihrss.io/top/#{time}"
    res = RestClient.get(url)
    rss = RSS::Parser.parse(res.body)
    rss.items.map do |item|
      IndiehackersItem.from(item)
    end
  end
end
