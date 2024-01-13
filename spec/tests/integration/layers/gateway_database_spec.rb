# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Integration Tests of Spotify API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store episode' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save *episode* from Spotify API to database' do
      episode = TranSound::Podcast::EpisodeMapper.new(TEMP_TOKEN).find(EPISODE_TYPE, EPISODE_ID, MARKET)

      rebuilt = TranSound::Repository::For.entity(episode).create(episode)

      _(rebuilt.origin_id).must_equal(episode.origin_id)
      _(rebuilt.description).must_equal(episode.description)
      _(rebuilt.images).must_equal(episode.images)
      _(rebuilt.language).must_equal(episode.language)
      _(rebuilt.name).must_equal(episode.name)
      _(rebuilt.release_date).must_equal(episode.release_date)
      _(rebuilt.type).must_equal(episode.type)
    end
  end

  describe 'Retrieve and store show' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save *show* from Spotify API to database' do
      show = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find(SHOW_TYPE, SHOW_ID, MARKET)

      rebuilt = TranSound::Repository::For.entity(show).create(show)

      _(rebuilt.origin_id).must_equal(show.origin_id)
      _(rebuilt.description).must_equal(show.description)
      _(rebuilt.images).must_equal(show.images)
      _(rebuilt.name).must_equal(show.name)
      _(rebuilt.publisher).must_equal(show.publisher)
      _(rebuilt.type).must_equal(show.type)
    end
  end
end
