class SyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sync_#{params[:auth_id]}"
  end

  def read(data)
    ActionCable.server.broadcast("sync_#{params[:auth_id]}", data)
  end

  def unread(data)
    ActionCable.server.broadcast("sync_#{params[:auth_id]}", data)
  end

  def sync(data)
    ActionCable.server.broadcast("sync_#{params[:auth_id]}", data)
  end
end