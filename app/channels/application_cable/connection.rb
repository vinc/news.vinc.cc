module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_user_with_hmac
    end

    def find_user_with_hmac
      token = request.params[:token]
      message = "#{request.method} #{request.path}"

      if (user = User.find_with_hmac(token, message))
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
