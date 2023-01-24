# frozen_string_literal: true

class Query
  include Mongoid::Document
  include Mongoid::Timestamps

  field :encrypted_query

  embedded_in :user
end
