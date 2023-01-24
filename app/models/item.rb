class Item
  include ActiveModel::Model

  attr_accessor :author, :created_at, :updated_at, :title, :text, :html, :image, :url, :via, :counts

  def self.from_hash(_hash)
    new # Extract attributes from hash and pass them to the initializer
  end

  def updated_at
    @updated_at || @created_at
  end
end
