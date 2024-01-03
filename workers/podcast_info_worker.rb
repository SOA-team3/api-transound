# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to map episode in parallel
class EpisodeWorker
  puts 'EpisodeWorker Start'
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
  puts "worker, access_key_id: #{config.AWS_ACCESS_KEY_ID},
  secret_access_key: #{config.AWS_SECRET_ACCESS_KEY},
  region: #{config.AWS_REGION}"

  include Shoryuken::Worker
  shoryuken_options queue: config.ADD_PODCAST_INFO_QUEUE_URL, auto_delete: true
  puts "worker, URL1: #{config.ADD_PODCAST_INFO_QUEUE_URL}"

  def perform(_sqs_msg, request)
    puts 'podcast_info_worker.rb start'
    puts "worker, URL2: #{config.ADD_PODCAST_INFO_QUEUE_URL}"
    config = YAML.safe_load_file('config/temp_token.yml')
    temp_token = config['spotify_temp_token']
    result = TranSound::Podcast::EpisodeMapper
      .new(temp_token)
      .find('episodes', request, 'TW')
    puts "worker: #{result}"
    result
  rescue StandardError => e
    puts "Error in perform: #{e.message}"
    puts e.backtrace.join("\n")
    puts 'EPISODE EXISTS -- ignoring request'
  end
end
