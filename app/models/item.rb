class Item
  include ActiveModel::Model

  attr_accessor :created_at, :title, :text, :html, :image, :url, :via, :counts

  def self.from_hash(hash)
    self.new # Extract attributes from hash and pass them to the initializer
  end
end
