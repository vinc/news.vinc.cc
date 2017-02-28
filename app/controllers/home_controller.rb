class HomeController < ApplicationController
  def index
    @query = search_params[:q] || ''

    case @query.split.first
    when 'hackernews', 'hn'
      @source = HackernewsSource.new
    when 'reddit', 'r'
      @source = RedditSource.new
    when 'twitter', 't'
      @source = TwitterSource.new
    when 'wikipedia', 'w'
      @source = WikipediaSource.new
    end
    @results = @source.search(@query) if @source
  end

  private

  def search_params
    params.permit(:q)
  end
end
