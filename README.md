# README

https://news.vinc.cc

## Examples

- https://news.vinc.cc/search?q=hackernews // hackernews homepage
- https://news.vinc.cc/search?q=hn+sort:top+limit:10 // filters
- https://news.vinc.cc/search?q=hn+rust+time:month // hackernews search
- https://news.vinc.cc/search?q=reddit+programming // subreddit
- https://news.vinc.cc/search?q=r+askscience+science+space // multireddit
- https://news.vinc.cc/search?q=r+news+worldnews+sort:top+time:week+limit:10
- https://news.vinc.cc/search?q=twitter+exoplanets // twitter search
- https://news.vinc.cc/search?q=t+exoplanets+type:recent+limit:100
- https://news.vinc.cc/search?q=t+puppy+filter:images+type:popular+sort:top
- https://news.vinc.cc/search?q=wikipedia+current+events // wikipedia special news page
- https://news.vinc.cc/search?q=w+current+events+time:week

## Self-hosting

This web app can run on your own server! You will need Redis to cache the HTTP
requests it's making to its news sources, and Mongo to store the user data
encrypted on the client side without knowing the key. The latter is completely
optional if you don't intend to synchronize between devices.

Heroku or a similar self-hosted PaaS like [Dokku](http://dokku.viewdocs.io/dokku/)
is recommended. Here is the setup with the latter:

```bash
# Dokku setup
dokku plugin:install https://github.com/dokku/dokku-redis.git redis
dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
dokku config:set --global DOKKU_LETSENCRYPT_EMAIL=alice@example.com

# App setup
dokku apps:create news
dokku domains:add news news.example.com
dokku config:set news TWITTER_KEY=xxxxx
dokku config:set news TWITTER_SECRET=xxxxx
dokku config:set news NEWSAPI_KEY=xxxxx
dokku config:set news REHOST_URL=https://rehost.vinc.cc
dokku letsencrypt news
dokku redis:create news-redis
dokku redis:link news-redis news
dokku mongo:create news-database
dokku mongo:link news-database news
```

You can then deploy like this:

```bash
git remote add dokku dokku@dokku.example.com:news
git push dokku master
```

You can also try it locally like this:

```bash
bundle install
rails server
```

This web app uses https://github.com/vinc/rehost to rehost image, but in the
future this will be integrated in the app.


## License

Copyright (c) 2017-2020 Vincent Ollivier. Released under MIT.
