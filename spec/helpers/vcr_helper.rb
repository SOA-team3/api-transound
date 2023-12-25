# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  PODCAST_CASSETTE = 'podcast_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true # for acceptance tests
      c.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      c.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_podcast
    VCR.configure do |c|
      c.filter_sensitive_data('<SPOTIFY_TOKEN>') { TEMP_TOKEN }
      c.filter_sensitive_data('<SPOTIFY_TOKEN_ESC>') { CGI.escape(TEMP_TOKEN) }
    end

    VCR.insert_cassette(
      PODCAST_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
