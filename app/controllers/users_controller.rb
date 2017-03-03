class UsersController < ApplicationController
  before_action :authenticate, except: %i(create)

  def show
  end

  def create
    @current_user = User.create
    respond_to do |format|
      format.json { render :show, status: :ok, location: @current_user }
    end
  end

  def update
    @current_user.generate_api_key
    @current_user.generate_api_secret
    @current_user.save

    respond_to do |format|
      format.json { render :show, status: :ok, location: @current_user }
    end
  end

  def destroy
    @current_user.destroy
    respond_to :json
  end

  def read
    @permalink = @current_user.permalinks.find_or_create_by(permalink_params)
    SyncChannel.broadcast_to(@current_user, permalink_params.merge(action: 'read'))

    respond_to do |format|
      format.json { render :show, status: :ok, location: @current_user }
    end
  end

  def unread
    @current_user.permalinks.where(permalink_params).delete
    SyncChannel.broadcast_to(@current_user, permalink_params.merge(action: 'unread'))

    respond_to do |format|
      format.json { render :show, status: :ok, location: @current_user }
    end
  end

  private

  def permalink_params
    params.require(:permalink).permit(:encrypted_permalink)
  end
end
