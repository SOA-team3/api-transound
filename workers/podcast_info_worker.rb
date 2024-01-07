# frozen_string_literal: true


require_relative '../require_app'
require_relative 'podcast_info_monitor'
require_relative 'job_reporter'
require_app


require 'figaro'
require 'shoryuken'
require 'json'


module EpisodeInfo
  # Shoryuken worker class to map episode in parallel
  class EpisodeWorker
    puts 'EpisodeWorker Start'
    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: App.config
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
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
    shoryuken_options queue: config.ADD_PODCAST_INFO_QUEUE_URL, auto_delete: true
    puts "worker, URL1: #{config.ADD_PODCAST_INFO_QUEUE_URL}"


    token_yml = YAML.safe_load_file('config/temp_token.yml')
    puts "worker, #{token_yml}"
    @temp_token = token_yml['spotify_temp_token']


    def perform(_sqs_msg, request)
      puts 'podcast_info_worker.rb start'
      puts "worker, request: #{request}"


      job = JobReporter.new(request, EpisodeWorker.config)
      puts "worker, config: #{EpisodeWorker.config}"


      job.report_each_second(3) { PodcastInfoMonitor.starting_percent }


      result = TranSound::Podcast::EpisodeMapper
        .new(job.token)
        .find('episodes', job.id, 'TW')


      job.report_each_second(3) { PodcastInfoMonitor.mapper_done }


      TranSound::Repository::For.entity(result).create(result)


      job.report_each_second(5) { PodcastInfoMonitor.finished_percent }
    rescue StandardError => e
      puts "Error in perform: #{e.message}"
      puts e.backtrace.join("\n")
      puts 'EPISODE EXISTS -- ignoring request'
    end


    private


    def epimapper(temp_token, id); end
  end
end



