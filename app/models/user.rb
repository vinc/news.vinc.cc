class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :auth_id,     default: -> { generate_auth_id }
  field :auth_secret, default: -> { generate_auth_secret }

  embeds_many :permalinks
  embeds_many :queries

  def to_param
    auth_id
  end

  def generate_auth_id
    self.auth_id = SecureRandom.uuid
  end

  def generate_auth_secret
    self.auth_secret = SecureRandom.hex(32)
  end

  def self.find_with_hmac(token, message)
    return nil if token.nil? || message.nil?

    client_id, client_mac = token.split(":")
    return nil if client_id.nil? || client_mac.nil?

    user = where(auth_id: client_id).first
    return nil if user.nil?

    server_secret = user.auth_secret

    server_mac = OpenSSL::HMAC.hexdigest("SHA256", server_secret, message)

    return unless ActiveSupport::SecurityUtils.secure_compare(server_mac, client_mac)

    user
  end
end
