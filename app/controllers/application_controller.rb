class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def authenticate
    authenticate_with_hmac || render_unauthorized
  end

  def authenticate_with_hmac
    authenticate_with_http_token do |token, options|
      client_id, client_mac = token.split(':')
      return false if client_id.nil? || client_mac.nil?

      user = User.where(auth_id: client_id).first
      return false if user.nil?

      server_secret = user.auth_secret

      message = "#{request.method} #{request.path}"

      server_mac = OpenSSL::HMAC.hexdigest('SHA256', server_secret, message)

      if ActiveSupport::SecurityUtils.secure_compare(server_mac, client_mac)
        @current_user = user
      else
        return false
      end
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Bearer realm="Sync"'
    render json: { message: 'Bad authentication header' }, status: 401
  end
end
