# frozen_string_literal: true

json.extract! query, :id, :encrypted_query, :created_at
json.url user_query_url(query, format: :json)
