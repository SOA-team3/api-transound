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

    it 'SAD: should not give view for an unwatched episode' do
      # GIVEN: a valid episode exists locally and is being watched
      spot_episode = TranSound::Podcast::EpisodeMapper
        .new(TEMP_TOKEN)
        .find(EPISODE_TYPE, EPISODE_ID, MARKET)
      TranSound::Repository::For.entity(spot_episode)
        .create(spot_episode)

      # WHEN: we request to view the episode (not sure)
      request = Struct.new(
        type: EPISODE_TYPE,
        id: EPISODE_ID
      )

      result = Service::ViewPodcastInfo.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end

    it 'SAD: should not give view for non-existene episode' do
      # GIVEN: no episode exists locally

      # WHEN: we request to view the episode
      request = Struct.new(
        type: EPISODE_TYPE,
        id: EPISODE_ID
      )

      result = Service::ViewPodcastInfo.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end

  describe 'View a Show' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'SAD: should not give view for an unwatched show' do
      # GIVEN: a valid episode exists locally and is being watched
      spot_show = TranSound::Podcast::ShowMapper
        .new(TEMP_TOKEN)
        .find(SHOW_TYPE, SHOW_ID, MARKET)
      TranSound::Repository::For.entity(spot_show)
        .create(spot_show)

      # WHEN: we request to view the episode (not sure)
      request = Struct.new(
        type: SHOW_TYPE,
        id: SHOW_ID
      )

      result = Service::ViewPodcastInfo.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end

    it 'SAD: should not give view for non-existene show' do
      # GIVEN: no episode exists locally

      # WHEN: we request to view the episode
      request = Struct.new(
        type: SHOW_TYPE,
        id: SHOW_ID
      )

      result = Service::ViewPodcastInfo.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end
end
