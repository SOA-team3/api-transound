#  frozen_string_literal: true

require_relative '../../../helpers/spec_helper'

describe 'Tests Podcast API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
    c.filter_sensitive_data('<SPOTIFY_TOKEN>') { TEMP_TOKEN }
    c.filter_sensitive_data('<SPOTIFY_TOKEN_ESC>') { CGI.escape(TEMP_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Episode information' do
    it 'HAPPY: should provide correct episode information' do
      episode = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find(EPISODE_TYPE, EPISODE_ID, MARKET)
      _(episode.description).must_equal EPISODE_CORRECT['description']

      # Assert the first image URL within the images array
      _(episode.images).must_equal EPISODE_CORRECT['images'][0]['url']
      _(episode.name).must_equal EPISODE_CORRECT['name']
      _(episode.release_date).must_equal EPISODE_CORRECT['release_date']
      _(episode.type).must_equal EPISODE_CORRECT['type']
    end

    it 'SAD: should raise exception on incorrect project' do
      _(proc do
        TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find(EPISODE_TYPE, 'BAD_ID', MARKET)
      end).must_raise TranSound::Podcast::Api::Response::BadRequest
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        TranSound::Podcast::EpisodeMapper.new('BAD_TOKEN').find(EPISODE_TYPE, EPISODE_ID, MARKET)
      end).must_raise TranSound::Podcast::Api::Response::Unauthorized
    end
  end

  describe 'Show information' do
    it 'HAPPY: should provide correct episode information' do
      show = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find(SHOW_TYPE, SHOW_ID, MARKET)
      _(show.description).must_equal SHOW_CORRECT['description']
      _(show.images).must_equal SHOW_CORRECT['images'][0]['url']
      _(show.name).must_equal SHOW_CORRECT['name']
      _(show.publisher).must_equal SHOW_CORRECT['publisher']
    end

    it 'SAD: should raise exception on incorrect project' do
      _(proc do
        TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find(SHOW_TYPE, 'BAD_ID', MARKET)
      end).must_raise TranSound::Podcast::Api::Response::BadRequest
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        TranSound::Podcast::ShowMapper.new('BAD_TOKEN').find(SHOW_TYPE, SHOW_ID, MARKET)
      end).must_raise TranSound::Podcast::Api::Response::Unauthorized
    end
  end
end
