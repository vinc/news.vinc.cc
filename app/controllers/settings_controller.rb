# frozen_string_literal: true

class SettingsController < ApplicationController
  def edit
    @sync_id = SecureRandom.hex(24)
  end
end
