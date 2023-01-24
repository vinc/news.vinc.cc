class HackernewsItem < Item
  def self.from_hash(hash)
    via = "https://news.ycombinator.com/item?id=#{hash['id'] || hash['objectID']}"
    url = hash["url"].nil? || hash["url"].start_with?("item?id=") ? via : hash["url"]

    new(
      author: hash["user"] || hash["author"],
      created_at: Time.at(hash["time"] || hash["created_at_i"]),
      title: hash["title"],
      url: url,
      via: via,
      counts: Counts.new(
        points: hash["points"],
        comments: hash["comments_count"] || hash["num_comments"]
      )
    )
  end
end
