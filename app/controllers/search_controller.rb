class SearchController < ApplicationController
  def index
    expires_in 5.minutes, public: true

    set_search(:search)
  end

  def autocomplete
    expires_in 1.hour, public: true

    set_search(:autocomplete)

    if @source.nil?
      sources = Source.all.map { |s| s.new.to_s }
      @results = sources.keep_if { |s| s.starts_with?(@query) }
    end

    render json: @results.delete_if { |s| s.strip == @query.strip }
  end

  private

  def set_search(search_type)
    @query = search_params[:q] || ''
    @source = Source.from_s(@query[/\w+/])
    if @source
      @query[/\w+/] = @source.to_s # Resolve shortcut notation
      @results = @source.send(search_type, @query)
    end
  end

  def search_params
    params.permit(:q)
  end
end
