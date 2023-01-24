class WikipediaItem < Item
  def self.from_hash(hash)
    created_at = nil
    text = nil
    html = nil
    hash["revisions"].each do |revision|
      created_at = Time.parse(revision["timestamp"])
      text = ""
      is_text = false
      revision["*"].lines.each do |line|
        is_text = false if line =~ /news \w+ above this line/
        text += line if is_text
        is_text = true if line =~ /news \w+ below this line/
      end
      html = WikiParser.new(data: text).to_html
    end

    new(
      created_at: created_at,
      title: hash["title"],
      via: hash["fullurl"],
      url: hash["fullurl"],
      text: text,
      html: html
    )
  end
end

class WikiParser < WikiCloth::Parser
  url_for do |page|
    "https://en.wikipedia.org/wiki/#{page}"
  end
end
