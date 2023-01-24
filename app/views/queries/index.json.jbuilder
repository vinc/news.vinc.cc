# frozen_string_literal: true

json.array! @queries, partial: "queries/query", as: :query
