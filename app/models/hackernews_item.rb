class HackernewsItem < Item
  def self.from_hash(hash)
    via = "https://news.ycombinator.com/item?id=#{hash['id']}"
    url = hash['url'].start_with?('item?id=') ? via : hash['url']

    self.new(
      author: hash['user'],
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
