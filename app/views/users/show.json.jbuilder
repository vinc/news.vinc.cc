# frozen_string_literal: true

json.extract! @current_user, :auth_id, :auth_secret, :created_at, :updated_at
json.url user_url(@current_user, format: :json)
