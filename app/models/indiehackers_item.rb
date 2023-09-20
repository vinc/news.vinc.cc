# frozen_string_literal: true

class IndiehackersItem < Item
  def self.from(item)
    new(
      author: "",
      created_at: item.date,
      title: item.title,
      url: item.link,
      via: item.link,
      counts: Counts.new(
        points: nil,
        comments: nil
      )
    )
  end
end
