# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'ViewPodcastInfo Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'View an Episode' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return episodes that are being watched' do
      # GIVEN: a valid episode exists locally and is being watched
      spot_episode = TranSound::Podcast::EpisodeMapper
        .new(TEMP_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID, MARKET)
      db_episode = TranSound::Repository::For.entity(spot_episode)
        .create(spot_episode)

      watched_list = ["podcast_info/#{EPISODE_TYPE}/#{EPISODE_ID}"]

      # WHEN: we requested a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: we should see our episode in the resulting list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_inclue db_episode
    end

    it 'HAPPY: should not return episodes that are not being watched' do
      # GIVEN: a valid episode exists locally but is not being watched
      spot_episode = TranSound::Podcast::EpisodeMapper
        .new(TEMP_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID, MARKET)
      TranSound::Repository::For.entity(spot_episode)
        .create(spot_episode)

      watched_list = []

      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_inclue []
    end

    it 'SAD: should not watched episodes if they are not loaded' do
      # GIVEN: we are watching a episode that does not exist locally
      watched_list = ["podcast_info/#{EPISODE_TYPE}/#{EPISODE_ID}"]

      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListEpisodes.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      episodes = result.value!
      _(episodes).must_inclue []
    end
  end

  describe 'View a Show' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return shows that are being watched' do
      # GIVEN: a valid show exists locally and is being watched
      spot_show = TranSound::Podcast::ShowMapper
        .new(TEMP_TOKEN)
        .find(SHOW_TYPE, SHOW_ID, MARKET)
      db_show = TranSound::Repository::For.entity(spot_show)
        .create(spot_show)

      watched_list = ["podcast_info/#{SHOW_TYPE}/#{SHOW_ID}"]

      # WHEN: we requested a list of all watched shows
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: we should see our show in the resulting list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_inclue db_show
    end

    it 'HAPPY: should not return shows that are not being watched' do
      # GIVEN: a valid show exists locally but is not being watched
      spot_show = TranSound::Podcast::ShowMapper
        .new(TEMP_TOKEN)
        .find(SHOW_TYPE, SHOW_ID, MARKET)
      TranSound::Repository::For.entity(spot_show)
        .create(spot_show)

      watched_list = []

      # WHEN: we request a list of all watched shows
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_inclue []
    end

    it 'SAD: should not watched episodes if they are not loaded' do
      # GIVEN: we are watching a episode that does not exist locally
      watched_list = ["podcast_info/#{SHOW_TYPE}/#{SHOW_ID}"]

      # WHEN: we request a list of all watched episodes
      result = TranSound::Service::ListShows.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      shows = result.value!
      _(shows).must_inclue []
    end
  end
end
