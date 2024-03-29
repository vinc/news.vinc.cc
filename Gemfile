# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.7.7"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.8.1"
# Use Puma as the app server
gem "puma", "~> 6.1"
# Use SCSS for stylesheets
gem "sassc-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "bootsnap", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", "~> 3.8.0"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1.0"

  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

gem "bootstrap", "~> 5.3.1"
gem "mongoid", "~> 6.1.0"
gem "redis"
gem "redis-rails"
gem "rest-client"
gem "twitter"
gem "twitter-text"
gem "wikicloth", github: "nricciar/wikicloth" # last gem release v0.8.3 is outdated
gem "rss"

source "https://rails-assets.org" do
  gem "rails-assets-core-typeahead"
  gem "rails-assets-crypto-js"
  gem "rails-assets-store"
  gem "rails-assets-tether", ">= 1.3.3"
end

group :test do
  gem "capybara"
  gem "rspec-rails", "~> 5.1"
end
