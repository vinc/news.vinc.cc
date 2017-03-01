class WikipediaItem < Item
  def self.from_hash(hash)
    created_at = nil
    text = nil
    html = nil
    hash['revisions'].each do |revision|
      created_at = Time.parse(revision['timestamp'])
      text = revision['*'].
        gsub(/\s*<!-- \w+ news \w+ above this line -->\|}/, '')
      html = WikiParser.new(:data => text).to_html
    end

    self.new(
      created_at: created_at,
      title: hash['title'],
      via: hash['fullurl'],
      url: hash['fullurl'],
      text: text,
      html: html
    )
  end

  private

  class WikiParser < WikiCloth::Parser
    url_for do |page|
      "https://en.wikipedia.org/wiki/#{page}"
    end
  end
end
