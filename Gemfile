# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.0'
gem 'pry'
gem 'rack-test'
gem 'rake'

# Presentation layer
gem 'multi_json', '~> 1.15'
gem 'roar', '~> 1.1'

# Web Application
gem 'puma', '~> 6'
gem 'rack-session', '~> 0.3'
gem 'roda', '~> 3'
gem 'slim', '~> 5'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Validation
gem 'dry-struct', '~> 1'
gem 'dry-types', '~> 1'

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

# Testing
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
