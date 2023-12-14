# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# CONFIGURATION
# Configuration and Utilities
gem 'figaro', '~> 1.0'
gem 'pry'
gem 'rake'

# APPLICATION LAYER
# Web Application related
gem 'multi_json', '~> 1.15'
gem 'puma', '~> 6'
gem 'rack-session', '~> 0.3'
gem 'roar', '~> 1.0'
gem 'roda', '~> 3'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Caching
gem 'rack-cache', '~> 1.13'
gem 'redis', '~> 4.8'
gem 'redis-rack-cache', '~> 2.2'

# Validation
gem 'dry-struct', '~> 1'
gem 'dry-types', '~> 1'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 5.1'

# data preprocessing
gem 'json'
gem 'tzinfo'
gem 'yaml'

# Database
gem 'hirb'
# gem 'hirb-unicode' # incompatible with new rubocop
gem 'sequel', '~> 5.0'

group :development, :test do
  gem 'sqlite3', '~> 1.0'
end

group :production do
  gem 'pg', '~> 1.2'
end

# TESTING
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'simplecov', '~> 0.0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'
end

# Development
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rerun', '~> 0.0'
  gem 'rubocop', '~> 1.0'
end
