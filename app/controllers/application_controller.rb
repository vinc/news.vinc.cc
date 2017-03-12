class ApplicationController < ActionController::Base
  #protect_from_forgery

  private

  def authenticate
    authenticate_with_hmac || render_unauthorized
  end

  def authenticate_with_hmac
    authenticate_with_http_token do |token, options|
      message = "#{request.method} #{request.path}"
      @current_user = User.find_with_hmac(token, message)
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Bearer realm="Sync"'
    render json: { message: 'Bad authentication header' }, status: 401
  end
end
