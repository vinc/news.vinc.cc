class TwitterSource < Source
  def initialize
    @title = 'Twitter'
    @url = 'https://twitter.com'
  end

  # https://dev.twitter.com/rest/public/search
  def request(args, options={})
    limit = (1..100).include?(options[:limit]) ? options[:limit] : 15
    options.delete(:limit)

    type = %i(recent popular mixed).include?(options[:type]) ? options[:type] : :mixed
    options.delete(:type)

    sort = %i(new hot top).include?(options[:sort]) ? options[:sort] : :hot
    options.delete(:sort)

    # merge the remaining options with the query
    query = args[1..-1].join('+') + ' ' + options.map { |a| a.join(':') }.join(' ')

    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_KEY']
      config.consumer_secret = ENV['TWITTER_SECRET']
    end

    tweets = client.search(query, :result_type => type).take(limit)
    tweets = tweets.sort_by { |tweet| -tweet.retweet_count } if sort == :top
    tweets = tweets.sort_by { |tweet| -tweet.created_at.to_i } if sort == :new

    tweets.map do |tweet|
      TwitterItem.from_tweet(tweet)
    end
  rescue Twitter::Error::BadRequest
  end
end
