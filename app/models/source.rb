# frozen_string_literal: true

class Source
  attr_reader :filters, :title, :url, :source_title, :source_url

  def initialize
    @filters = {}
  end

  def search(query)
    before_search(query) if respond_to?(:before_search)

    opts = {}
    args = query.split.each_with_object([]) do |word, acc|
      case word
      when /(\w+):(\w+)/
        opts[::Regexp.last_match(1).to_sym] = begin
          Integer(::Regexp.last_match(2))
        rescue StandardError
          ::Regexp.last_match(2).to_sym
        end
      else
        acc << word
      end
    end

    Rails.cache.fetch(query, expires_in: 5.minutes) do
      request(args, opts)
    end
  end

  def request(_args, _opts = {})
    []
  end

  def get_suggestions(_query)
    []
  end

  def autocomplete(query)
    before_autocomplete(query) if respond_to?(:before_autocomplete)

    suggestions = get_suggestions(query)

    words = query.split(" ", -1)
    current_word = words.size > 1 ? words.pop : ""
    query = words.join(" ")

    @filters.each_key do |filter|
      name = filter.to_s.singularize
      suggestions += @filters[filter].map { |s| "#{name}:#{s}" } unless query["#{name}:"]
    end

    suggestions.delete_if do |suggestion|
      words.include?(suggestion) || !suggestion.starts_with?(current_word)
    end

    suggestions.map { |suggestion| "#{query} #{suggestion}" }
  end

  def to_s
    self.class.to_s.downcase.sub("source", "")
  end

  ALIASES = {
    "hn" => "hackernews",
    "ih" => "indiehackers",
    "r" => "reddit",
    "t" => "twitter",
    "w" => "wikipedia"
  }.freeze

  # 'hackernews time:week' will return an instance of HackernewsSource
  # 'hn time:week' will also return an instance of HackernewsSource
  # 'unknown source' will return nil
  def self.from_s(source)
    source = ALIASES[source] if ALIASES.include?(source)
    Source.const_get("#{source.capitalize}Source").new
  rescue NameError
  end

  def self.all
    if descendants.empty?
      Dir["#{Rails.root}/app/models/*_source.rb"].each do |file|
        require_dependency file
      end
    end

    descendants
  end
end
