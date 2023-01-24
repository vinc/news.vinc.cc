class NewsapiItem < Item
  def self.from_hash(hash)
    time = hash["publishedAt"] ? Time.parse(hash["publishedAt"]) : nil

    new(
      author: hash["author"],
      created_at: time,
      title: hash["title"],
      html: hash["description"],
      url: hash["url"],
      via: hash["url"],
      image: hash["urlToImage"]
    )
  end
end
