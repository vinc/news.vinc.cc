# frozen_string_literal: true

class Counts
  include ActiveModel::Model

  attr_accessor :points, :comments, :retweets, :favorites

  def each
    %w[point comment retweet favorite].each do |k|
      v = send(k.pluralize.to_sym)
      yield(k, v) unless v.nil?
    end
  end
end
