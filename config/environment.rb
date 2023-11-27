# frozen_string_literal: true

require 'figaro'
require 'logger'
require 'rack/session'
require 'roda'
require 'sequel'
# require 'yaml'
# require 'delegate' # needed until Rack 2.3 fixes delegateclass bug

# Get TranSound::Token class
require_relative '../app/infrastructure/gateways/podcast_api'

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

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
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
