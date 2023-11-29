# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  TranSound::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_podcast
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'View episode folder route' do
    it 'should be able to view a episode' do
      TranSound::Service::AddEpisode.new.call(
        episode_type: EPISODE_TYPE, episode_id: EPISODE_ID, market: MARKET
      )
      get "/api/v1/podcast_info/#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder episode]
      _(result['episode']['origin_id']).must_equal EPISODE_ID
      _(result['episode']['type']).must_equal EPISODE_TYPE
      _(result['episode']['market']).must_equal MARKET
      _(result['folder']['path']).must_equal ''
      _(result['folder']['subfolders'].count).must_equal 10
      _(result['folder']['line_count']).must_equal 1450
      _(result['folder']['base_files'].count).must_equal 2
    end

    it 'should be able to view a episode subfolder' do
      TranSound::Service::AddEpisode.new.call(
        episode_type: EPISODE_TYPE, episode_id: EPISODE_ID, market: MARKET
      )

      get "/api/v1/episodes/#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}/spec"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder episode]
      _(result['episode']['name']).must_equal EPISODE_ID
      _(result['episode']['type']).must_equal EPISODE_TYPE
      _(result['episode']['market']).must_equal MARKET
      _(result['folder']['path']).must_equal 'spec'
      _(result['folder']['subfolders'].count).must_equal 1
      _(result['folder']['line_count']).must_equal 151
      _(result['folder']['base_files'].count).must_equal 3
    end

    it 'should be report error for an invalid subfolder' do
      TranSound::Service::AddEpisode.new.call(
        episode_type: EPISODE_TYPE, episode_id: EPISODE_ID, market: MARKET
      )

      get "/api/v1/episodes/#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end

    it 'should be report error for an invalid episode' do
      TranSound::Service::AddEpisode.new.call(
        episode_type: 'episodes', EPISODE_ID: '2zplNaMpre0ASbFJV7OSSq'
      )

      get "/api/v1/episodes/#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Add episodes route' do
    it 'should be able to add a episode' do
      post "api/v1/episodes/#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}"

      _(last_response.status).must_equal 201

      episode = JSON.parse last_response.body
      _(episode['origin_id']).must_equal EPISODE_ID
      _(episode['type']).must_equal EPISODE_TYPE
      _(episode['market']).must_equal MARKET

      episode = TranSound::Representer::Episode.new(
        TranSound::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      _(episode.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid episodes' do
      post 'api/v1/episodes/2zplNaMpre0ASbFJV7OSSq/market=TW'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get episodes list' do
    it 'should successfully return episode lists' do
      TranSound::Service::AddEpisode.new.call(
        episode_type: EPISODE_TYPE, episode_id: EPISODE_ID, market: MARKET
      )

      list = ["#{EPISODE_TYPE}/#{EPISODE_ID}?market=#{MARKET}"]
      encoded_list = TranSound::Request::EncodedEpisodeList.to_encoded(list)

      get "/api/v1/episodes?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      episodes = response['episodes']
      _(episodes.count).must_equal 1
      episode = episodes.first
      _(episode['origin_id']).must_equal EPISODE_ID
      _(episode['type']).must_equal EPISODE_TYPE
      _(episode['market']).must_equal MARKET
    end

    it 'should return empty lists if none found' do
      list = ['djsafildafs;d/239eidj-fdjs']
      encoded_list = TranSound::Request::EncodedEpisodeList.to_encoded(list)

      get "/api/v1/episodes?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      episodes = response['episodes']
      _(episodes).must_be_kind_of Array
      _(episodes.count).must_equal 0
    end

    it 'should return error if not list provided' do
      get '/api/v1/episodes'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end

  describe 'View show folder route' do
    it 'should be able to view a show' do
      TranSound::Service::AddShow.new.call(
        show_type: SHOW_TYPE, show_id: SHOW_ID, market: MARKET
      )
      get "/api/v1/podcast_info/#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder show]
      _(result['show']['origin_id']).must_equal SHOW_ID
      _(result['show']['type']).must_equal SHOW_TYPE
      _(result['show']['market']).must_equal MARKET
      _(result['folder']['path']).must_equal ''
      _(result['folder']['subfolders'].count).must_equal 10
      _(result['folder']['line_count']).must_equal 1450
      _(result['folder']['base_files'].count).must_equal 2
    end

    it 'should be able to view a show subfolder' do
      TranSound::Service::AddShow.new.call(
        show_type: SHOW_TYPE, show_id: SHOW_ID, market: MARKET
      )

      get "/api/v1/shows/#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}/spec"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder show]
      _(result['show']['name']).must_equal SHOW_ID
      _(result['show']['type']).must_equal SHOW_TYPE
      _(result['show']['market']).must_equal MARKET
      _(result['folder']['path']).must_equal 'spec'
      _(result['folder']['subfolders'].count).must_equal 1
      _(result['folder']['line_count']).must_equal 151
      _(result['folder']['base_files'].count).must_equal 3
    end

    it 'should be report error for an invalid subfolder' do
      TranSound::Service::AddShow.new.call(
        show_type: SHOW_TYPE, show_id: SHOW_ID, market: MARKET
      )

      get "/api/v1/shows/#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end

    it 'should be report error for an invalid show' do
      TranSound::Service::AddShow.new.call(
        SHOW_type: 'shows', SHOW_ID: '5Vv32KtHB3peVZ8TeacUty'
      )

      get "/api/v1/shows/#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Add shows route' do
    it 'should be able to add a show' do
      post "api/v1/shows/#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}"

      _(last_response.status).must_equal 201

      show = JSON.parse last_response.body
      _(show['origin_id']).must_equal SHOW_ID
      _(show['type']).must_equal SHOW_TYPE
      _(show['market']).must_equal MARKET

      show = TranSound::Representer::SHOW.new(
        TranSound::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      _(show.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid shows' do
      post 'api/v1/shows/5Vv32KtHB3peVZ8TeacUty/market=TW'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get shows list' do
    it 'should successfully return show lists' do
      TranSound::Service::AddShow.new.call(
        show_type: SHOW_TYPE, show_id: SHOW_ID, market: MARKET
      )

      list = ["#{SHOW_TYPE}/#{SHOW_ID}?market=#{MARKET}"]
      encoded_list = TranSound::Request::EncodedShowList.to_encoded(list)

      get "/api/v1/shows?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      shows = response['shows']
      _(shows.count).must_equal 1
      show = shows.first
      _(show['origin_id']).must_equal SHOW_ID
      _(show['type']).must_equal SHOW_TYPE
      _(show['market']).must_equal MARKET
    end

    it 'should return empty lists if none found' do
      list = ['djsafildafs;d/239eidj-fdjs']
      encoded_list = TranSound::Request::EncodedShowList.to_encoded(list)

      get "/api/v1/shows?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      shows = response['shows']
      _(shows).must_be_kind_of Array
      _(shows.count).must_equal 0
    end

    it 'should return error if not list provided' do
      get '/api/v1/shows'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end
end
