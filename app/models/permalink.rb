class Permalink
  include Mongoid::Document
  include Mongoid::Timestamps

  field :encrypted_permalink

  embedded_in :user
end
