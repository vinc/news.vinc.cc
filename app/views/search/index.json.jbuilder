# frozen_string_literal: true

json.array! @results, partial: "search/item", as: :item
