class PermalinksController < ApplicationController
  before_action :authenticate
  before_action :set_permalink, only: %i(show destroy)

  def index
    @permalinks = @current_user.permalinks
  end

  def show
  end

  def create
    @permalink = @current_user.permalinks.create(permalink_params)
    respond_to do |format|
      format.json { render :show, status: :created, location: user_permalinks_url(@permalink, format: :json) }
    end
  end

  def destroy
    @permalink.destroy
    respond_to :json
  end

  private

  def permalink_params
    params.require(:permalink).permit(:encrypted_permalink)
  end

  def set_permalink
    @current_user.find_by(encrypted_permalink: permalink_params[:encrypted_permalink])
  end
end
