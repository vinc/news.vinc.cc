# frozen_string_literal: true

json.extract! permalink, :id, :encrypted_permalink, :created_at
json.url user_permalink_url(permalink, format: :json)
