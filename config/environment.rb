# frozen_string_literal: true

require 'figaro'
require 'logger'
require 'rack/session'
require 'roda'
require 'sequel'
require 'yaml'
require 'rack/cache'
require 'redis-rack-cache'

# Get TranSound::Token class
require_relative '../app/infrastructure/gateways/podcast_api'

# SECRET_PATH = 'config/secrets.yml'
# CONFIG = YAML.safe_load_file(SECRET_PATH)
# CLIENT_ID = CONFIG['test']['spotify_Client_ID']
# CLIENT_SECRET = CONFIG['test']['spotify_Client_secret']
# puts "CONFIG: #{CONFIG}"
# puts "CLIENT_SECRET: #{CLIENT_SECRET}"

# Temp ENV handle
# TEMP_TOKEN_PATH = 'config/temp_token.yml'
# TEMP_TOKEN_CONFIG = YAML.safe_load_file(TEMP_TOKEN_PATH)

module TranSound
  # Configuration for the App
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      use Rack::Session::Cookie, secret: config.SESSION_SECRET

      configure :development, :test, :app_test do
        require 'pry'; # for breakpoints
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      configure :development, :production do
        plugin :common_logger, $stderr
      end

      # Setup Cacheing mechanism
      configure :development do
        use Rack::Cache,
            verbose: true,
            metastore: 'file:_cache/rack/meta',
            entitystore: 'file:_cache/rack/body'
      end

      configure :production do
        use Rack::Cache,
            verbose: true,
            metastore: "#{config.REDIS_URL}/0/metastore",
            entitystore: "#{config.REDIS_URL}/0/entitystore"
      end

      # Automated HTTP stubbing for testing only
      configure :app_test do
        require_relative '../spec/helpers/vcr_helper'
        VcrHelper.setup_vcr
        VcrHelper.configure_vcr_for_github(recording: :none)
      end

      # Database Setup
      @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
      def self.db = @db # rubocop:disable Style/TrivialAccessors

      # Logger Setup
      @logger = Logger.new($stderr)
      def self.logger = @logger # rubocop:disable Style/TrivialAccessors
    end
  end
end
