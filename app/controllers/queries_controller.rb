class QueriesController < ApplicationController
  before_action :authenticate
  before_action :set_query, only: %i[show destroy]

  def index
    @queries = @current_user.queries
  end

  def show; end

  def create
    @query = @current_user.queries.find_or_create_by(query_params)
    SyncChannel.broadcast_to(@current_user, @query.as_document.merge(action: "save"))
    respond_to do |format|
      format.json { render :show, status: :created, location: user_queries_url(@query, format: :json) }
    end
  end

  def destroy
    SyncChannel.broadcast_to(@current_user, @query.as_document.merge(action: "unsave"))
    @query.destroy
    respond_to :json
  end

  private

  def query_params
    params.require(:query).permit(:id, :encrypted_query)
  end

  def set_query
    @query = @current_user.queries.find(query_params[:id])
  end
end
