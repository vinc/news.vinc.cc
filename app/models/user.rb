class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :auth_id,     default: -> { self.generate_auth_id }
  field :auth_secret, default: -> { self.generate_auth_secret }

  def generate_auth_id
    self.auth_id = SecureRandom.uuid
  end

  def generate_auth_secret
    self.auth_secret = SecureRandom.hex(32)
  end
end
