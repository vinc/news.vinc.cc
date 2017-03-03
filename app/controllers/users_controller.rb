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
end
