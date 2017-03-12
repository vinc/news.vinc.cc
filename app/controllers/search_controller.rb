class SearchController < ApplicationController
  def index
    expires_in 5.minutes, public: true

    @query = search_params[:q] || ''

    @source = Source.from_s(@query[/\w+/])

    if @source
      @query[/\w+/] = @source.to_s # Resolve shortcut notation
      @results = @source.search(@query)
    end
  end

  private

  def search_params
    params.permit(:q)
  end
end
