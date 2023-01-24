# frozen_string_literal: true

class SyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sync:#{params[:auth_id]}"
  end
end
