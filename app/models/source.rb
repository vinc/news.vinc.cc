class Source
  attr_reader :filters, :title, :url, :source_title, :source_url

  def initialize
    @filters = {}
  end

  def search(query)
    before_search(query) if self.respond_to?(:before_search)

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

  def get_suggestions(query)
    []
  end

  def autocomplete(query)
    before_autocomplete(query) if self.respond_to?(:before_autocomplete)

    suggestions = self.get_suggestions(query)

    words = query.split(' ', -1)

    if words.size > 1
      current_word = words.pop
      query = words.join(' ')

      @filters.keys.each do |filter|
        name = filter.to_s.singularize
        unless query["#{name}:"]
          suggestions += @filters[filter].map { |s| "#{name}:#{s}" }
        end
      end

      suggestions.delete_if do |suggestion|
        words.include?(suggestion) || !suggestion.starts_with?(current_word)
      end
    end

    suggestions.map { |suggestion| "#{query} #{suggestion}" }
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
