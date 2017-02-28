class Item
  include ActiveModel::Model

  attr_accessor :created_at, :title, :text, :html, :image, :url, :via, :counts
end
