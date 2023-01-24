# frozen_string_literal: true

class RedditItem < Item
  def self.from_hash(hash)
    image = nil
    (hash.dig("data", "preview", "images") || []).each do |img|
      width = 0
      img["resolutions"].each do |resolution|
        if width < resolution["width"]
          width = resolution["width"]
          image = resolution["url"].gsub("&amp;", "&")
        end
      end
    end

    new(
      author: hash["data"]["author"],
      created_at: Time.at(hash["data"]["created_utc"].to_i),
      title: hash["data"]["title"],
      url: hash["data"]["url"],
      via: "https://www.reddit.com#{hash['data']['permalink']}",
      image: image,
      counts: Counts.new(
        points: hash["data"]["score"],
        comments: hash["data"]["num_comments"]
      )
    )
  end
end
