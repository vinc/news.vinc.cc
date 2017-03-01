class HackernewsItem < Item
  def self.from_hash(hash)
    via = "https://news.ycombinator.com/hash?id=#{hash['id']}"
    url = hash['url'].start_with?('hash?id=') ? via : hash['url']

    self.new(
      created_at: Time.at(hash['time']),
      title: hash['title'],
      url: url,
      via: via,
      counts: Counts.new(
        points: hash['points'],
        comments: hash['comments_count']
      )
    )
  end
end
