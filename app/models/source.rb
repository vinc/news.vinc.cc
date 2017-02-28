class Source
  attr_reader :title, :url

  def search(query)
    opts = {}
    args = query.split.reduce([]) do |acc, word|
      case word
      when /(\w+):(\w+)/
        opts[$1.to_sym] = Integer($2) rescue $2.to_sym
      else
        acc << word
      end
      acc
    end

    Rails.cache.fetch(query, expires_in: 5.minutes) do
      request(args, opts)
    end
  end

  def request(args, opts={})
    []
  end
end
