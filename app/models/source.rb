class Source
  attr_reader :title, :url, :source_title, :source_url

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

    before_request(args, opts) if self.respond_to?(:before_request)

    Rails.cache.fetch(query, expires_in: 5.minutes) do
      request(args, opts)
    end
  end

  def request(args, opts={})
    []
  end

  def to_s
    self.class.to_s.downcase.sub('source', '')
  end

  ALIASES = {
    'hn' => 'hackernews',
    'r'  => 'reddit',
    't'  => 'twitter',
    'w'  => 'wikipedia'
  }.freeze

  # 'hackernews time:week' will return an instance of HackernewsSource
  # 'hn time:week' will also return an instance of HackernewsSource
  # 'unknown source' will return nil
  def self.from_s(source)
    source = ALIASES[source] if ALIASES.include?(source)
    Source.const_get("#{source.capitalize}Source").new
  rescue NameError
  end
end
