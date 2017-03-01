class SyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sync_#{params[:id]}"
  end

  def read(data)
    ActionCable.server.broadcast("sync_#{params[:id]}", data)
  end

  def unread(data)
    ActionCable.server.broadcast("sync_#{params[:id]}", data)
  end

  def sync(data)
    ActionCable.server.broadcast("sync_#{params[:id]}", data)
  end
end
