# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'AddEpisode Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store episode' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to find and save remote episode to database' do
      # GIVEN: a valid url request for an existing remote episode:
      episode = TranSound::Episode::EpisodeMapper
        .new(TEMP_TOKEN).find(EPISODE_TYPE, EPISODE_ID)
      url_request = TranSound::Forms::NewEpisode.new.call(remote_url: PD_URL)

      # WHEN: the service is called with the request form object
      episode_made = TranSound::Service::AddEpisode.new.call(url_request)

      # THEN: the result should report success..
      _(episode_made.success?).must_equal true

      # ..and provide a episode entity with the right details
      rebuilt = episode_made.value!
      _(rebuilt.origin_id).must_equal(episode.origin_id)
      _(rebuilt.description).must_equal(episode.description)
      _(rebuilt.images).must_equal(episode.images)
      _(rebuilt.language).must_equal(episode.language)
      _(rebuilt.name).must_equal(episode.name)
      _(rebuilt.release_date).must_equal(episode.release_date)
      _(rebuilt.type).must_equal(episode.type)
      _(rebuilt.episode_url).must_equal(episode.episode_url)
      _(rebuilt.episode_mp3_url).must_equal(episode.episode_mp3_url)
      _(rebuilt.transcript).must_equal(episode.transcript)
      _(rebuilt.translation).must_equal(episode.translation)
    end

    it 'HAPPY: should find and return existing episode in database' do
      # GIVEN: a valid url request for a episode already in the database:
      url_request = TranSound::Forms::NewEpisode.new.call(remote_url: PD_URL)
      db_episode = TranSound::Service::AddEpisode.new.call(url_request).value!

      # WHEN: the service is called with the request form object
      episode_made = TranSound::Service::AddEpisode.new.call(url_request)

      # THEN: the result should report success..
      _(episode_made.success?).must_equal true

      # ..and find the same episode that was already in the database
      rebuilt = episode_made.value!
      _(rebuilt.id).must_equal(db_episode.id)

      # ..and provide a episode entity with the right details
      rebuilt = episode_made.value!
      _(rebuilt.origin_id).must_equal(episode.origin_id)
      _(rebuilt.description).must_equal(episode.description)
      _(rebuilt.images).must_equal(episode.images)
      _(rebuilt.language).must_equal(episode.language)
      _(rebuilt.name).must_equal(episode.name)
      _(rebuilt.release_date).must_equal(episode.release_date)
      _(rebuilt.type).must_equal(episode.type)
      _(rebuilt.episode_url).must_equal(episode.episode_url)
      _(rebuilt.episode_mp3_url).must_equal(episode.episode_mp3_url)
      _(rebuilt.transcript).must_equal(episode.transcript)
      _(rebuilt.translation).must_equal(episode.translation)
    end

    it 'BAD: should gracefully fail for invalid episode url' do
      # GIVEN: an invalid url request is formed
      bad_gh_url = 'https://reurl.cc/Wv9vQ7'
      url_request = TranSound::Forms::NewEpisode.new.call(remote_url: bad_gh_url)

      # WHEN: the service is called with the request form object
      episode_made = TranSound::Service::AddEpisode.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(episode_made.success?).must_equal false
      _(episode_made.failure.downcase).must_include 'invalid'
    end

    it 'SAD: should gracefully fail for invalid episode url' do
      # GIVEN: an invalid url request is formed
      sad_gh_url = 'https://reurl.cc/Wv9vQ7'
      url_request = TranSound::Forms::NewEpisode.new.call(remote_url: sad_gh_url)

      # WHEN: the service is called with the request form object
      episode_made = TranSound::Service::AddEpisode.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(episode_made.success?).must_equal false
      _(episode_made.failure.downcase).must_include 'could not find'
    end
  end
end

describe 'Retrieve and store show' do
  before do
    DatabaseHelper.wipe_database
  end

  it 'HAPPY: should be able to find and save remote show to database' do
    # GIVEN: a valid url request for an existing remote show:
    show = TranSound::Show::ShowMapper
      .new(TEMP_TOKEN).find(SHOW_TYPE, SHOW_ID)
    url_request = TranSound::Forms::NewShow.new.call(remote_url: PD_URL)

    # WHEN: the service is called with the request form object
    show_made = TranSound::Service::AddShow.new.call(url_request)

    # THEN: the result should report success..
    _(show_made.success?).must_equal true

    # ..and provide a show entity with the right details
    rebuilt = show_made.value!
    _(rebuilt.origin_id).must_equal(show.origin_id)
    _(rebuilt.description).must_equal(show.description)
    _(rebuilt.images).must_equal(show.images)
    _(rebuilt.name).must_equal(show.name)
    _(rebuilt.publisher).must_equal(show.publisher)
    _(rebuilt.type).must_equal(show.type)
    _(rebuilt.show_url).must_equal(show.show_url)
  end

  it 'HAPPY: should find and return existing show in database' do
    # GIVEN: a valid url request for a show already in the database:
    url_request = TranSound::Forms::NewShow.new.call(remote_url: PD_URL)
    db_show = TranSound::Service::AddShow.new.call(url_request).value!

    # WHEN: the service is called with the request form object
    show_made = TranSound::Service::AddShow.new.call(url_request)

    # THEN: the result should report success..
    _(show_made.success?).must_equal true

    # ..and find the same show that was already in the database
    rebuilt = show_made.value!
    _(rebuilt.id).must_equal(db_show.id)

    # ..and provide a show entity with the right details
    rebuilt = show_made.value!
    _(rebuilt.origin_id).must_equal(show.origin_id)
    _(rebuilt.description).must_equal(show.description)
    _(rebuilt.images).must_equal(show.images)
    _(rebuilt.name).must_equal(show.name)
    _(rebuilt.publisher).must_equal(show.publisher)
    _(rebuilt.type).must_equal(show.type)
    _(rebuilt.show_url).must_equal(show.show_url)
  end

  it 'BAD: should gracefully fail for invalid show url' do
    # GIVEN: an invalid url request is formed
    bad_gh_url = 'https://reurl.cc/Wv9vQ7'
    url_request = TranSound::Forms::NewShow.new.call(remote_url: bad_gh_url)

    # WHEN: the service is called with the request form object
    show_made = TranSound::Service::AddShow.new.call(url_request)

    # THEN: the service should report failure with an error message
    _(show_made.success?).must_equal false
    _(show_made.failure.downcase).must_include 'invalid'
  end

  it 'SAD: should gracefully fail for invalid show url' do
    # GIVEN: an invalid url request is formed
    sad_gh_url = 'https://reurl.cc/Wv9vQ7'
    url_request = TranSound::Forms::NewShow.new.call(remote_url: sad_gh_url)

    # WHEN: the service is called with the request form object
    show_made = TranSound::Service::AddShow.new.call(url_request)

    # THEN: the service should report failure with an error message
    _(show_made.success?).must_equal false
    _(show_made.failure.downcase).must_include 'could not find'
  end
end
