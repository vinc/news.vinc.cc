class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :auth_id,     default: -> { self.generate_auth_id }
  field :auth_secret, default: -> { self.generate_auth_secret }

  embeds_many :permalinks
  embeds_many :queries

  def to_param
    self.auth_id
  end

  def generate_auth_id
    self.auth_id = SecureRandom.uuid
  end

  def generate_auth_secret
    self.auth_secret = SecureRandom.hex(32)
  end

  def self.find_with_hmac(token, message)
    client_id, client_mac = token.split(':')
    return nil if client_id.nil? || client_mac.nil?

    user = self.where(auth_id: client_id).first
    return nil if user.nil?

    server_secret = user.auth_secret

    server_mac = OpenSSL::HMAC.hexdigest('SHA256', server_secret, message)

    if ActiveSupport::SecurityUtils.secure_compare(server_mac, client_mac)
      user
    else
      nil
    end
  end
end
