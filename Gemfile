source 'http://rubygems.org'

gem 'rails', "~> 3.1.0"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'


# webserver must be explicit on new cedar stack
# using thin for all environments with Procfile
gem 'thin'

# queue system (used for SMS notifications and date expiration)
gem 'delayed_job'


# Rails 3.1 - Heroku
group :production, :staging do
  gem 'pg'
  gem 'dalli' # memcache on Heroku
  gem 'exceptional'
end

group :development do
  gem "rails3-generators"
end

group :test, :development do
  gem 'sqlite3'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

# TODO: remove immediate bellow line after upgrade...
# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# geokit-rails3 gem
gem 'geokit-rails3-1beta'

# twilio ruby gem
gem 'twiliolib'

# authlogic (rails3)
gem "authlogic"

# used to access Yelp API
gem "httparty", '=0.7.8'

# OAuth 1.0a needed to access Yelp API v2
gem "signet"

# simple email (temporary)
gem "pony"

# CarrierWave (avatar resizing and s3)
gem 'carrierwave'
gem 'mini_magick'	# wrapper to system's ImageMagick
gem 'fog'			# used to access s3
