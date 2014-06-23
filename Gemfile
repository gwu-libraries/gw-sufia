source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.5'

# Use PostgreSQL as the database for Active Record
gem 'pg'

# Use Thin for SSL webserver
gem 'thin'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'sufia', github: 'projecthydra/sufia', ref: '852ff7d46f7'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'  # required to handle pagination properly in dashboard. See https://github.com/amatsuda/kaminari/pull/322

gem 'bootstrap-sass', '< 3.2'
gem 'devise'
gem 'devise-guests', '~> 0.3'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0.1'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'capybara', '~> 2.3.0'
  gem 'jettywrapper'
end

group :development do
  gem 'unicorn-rails'
end
