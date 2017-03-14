class SearchController < ApplicationController
  def index
    expires_in 5.minutes, public: true

    set_query
    set_search(:search)
  end

  def autocomplete
    expires_in 1.hour, public: true

    set_query
    set_search(:autocomplete)

    if @source.nil?
      sources = Source.all.map { |s| s.new.to_s }
      @results = sources.keep_if { |s| s.starts_with?(@query) }

      if @results.count == 1
        # Autocomplete from the only source available
        @query = @results.first
        set_search(:autocomplete)
      end
    end

    render json: @results.delete_if { |s| s.strip == @query.strip }
  end

  private

  def set_query
    @query = search_params[:q] || ''
  end

  def set_search(search_type)
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
