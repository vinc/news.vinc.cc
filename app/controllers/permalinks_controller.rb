# frozen_string_literal: true

class PermalinksController < ApplicationController
  before_action :authenticate
  before_action :set_permalink, only: %i[show destroy]

  def index
    @permalinks = @current_user.permalinks
  end

  def show; end

  def create
    @permalink = @current_user.permalinks.find_or_create_by(permalink_params)
    SyncChannel.broadcast_to(@current_user, @permalink.as_document.merge(action: "read"))
    respond_to do |format|
      format.json { render :show, status: :created, location: user_permalinks_url(@permalink, format: :json) }
    end
  end

  def destroy
    SyncChannel.broadcast_to(@current_user, @permalink.as_document.merge(action: "unread"))
    @permalink.destroy
    respond_to :json
  end

  private

  def permalink_params
    params.require(:permalink).permit(:id, :encrypted_permalink)
  end

  def set_permalink
    @permalink = @current_user.permalinks.find(permalink_params[:id])
  end
end
