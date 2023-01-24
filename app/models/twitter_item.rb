# frozen_string_literal: true

class TwitterItem < Item
  def self.from_tweet(tweet)
    html = auto_link_with_json(tweet.text, tweet.to_hash[:entities], {
                                 hashtag_url_base: "/search?q=twitter+%23",
                                 username_url_base: "/search?q=twitter+@",
                                 username_include_symbol: true,
                                 suppress_no_follow: true
                               })
    html = "<p>#{html}</p>"
    image = nil
    tweet.media.each do |media|
      if media.is_a? Twitter::Media::Photo
        image = media.media_url_https.to_s
        break
      end
    end

    new(
      author: tweet.user.screen_name,
      created_at: tweet.created_at.dup,
      text: tweet.text,
      html: html,
      via: tweet.url.to_s,
      image: image,
      counts: Counts.new(
        retweets: tweet.retweet_count,
        favorites: tweet.favorite_count
      )
    )
  end
end
