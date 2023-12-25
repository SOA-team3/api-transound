# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to map episode in parallel
class EpisodeWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.ADD_PODCAST_INFO_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    puts "podcast_info_worker.rb start"
    temp_token_config = YAML.safe_load_file('config/temp_token.yml')
    temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                    App.config.spotify_Client_secret, temp_token_config).get
    puts "worker, #{request}"
    TranSound::Podcast::EpisodeMapper
      .new(temp_token)
      .find('episodes', request, 'TW')
  rescue StandardError
    puts 'EPISODE EXISTS -- ignoring request'
  end
end
