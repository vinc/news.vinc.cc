# frozen_string_literal: true

module ApplicationHelper
  include Twitter::TwitterText::Autolink

  def database_present?
    ENV["MONGO_URL"].present?
  end

  def thumbnailer_present?
    ENV["REHOST_URL"].present?
  end
end
