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

  # describe 'View episode route' do
  #   it 'should be able to view an episode' do
  #     TranSound::Service::AddPodcastInfo.new.call(
  #       type: 'episode', id: EPISODE_ID
  #     )
  #     get "/api/v1/podcast_info/episode/#{EPISODE_ID}"
  #     _(last_response.status).must_equal 200
  #     result = JSON.parse last_response.body
  #     _(result.keys.sort).must_equal %w[episode]
  #     _(result['episode']['origin_id']).must_equal EPISODE_ID
  #     _(result['episode']['type']).must_equal 'episode'
  #     _(result['episode']['description']).must_equal 'It turns out that hoverflies may fly hundreds or even
  #     thousands of miles—all to help pollinate our flowers and vegetables.'
  #     _(result['episode']['name']).must_equal 'These Tiny Pollinators Can Travel Surprisingly Huge Distances'
  #     _(result['episode']['release_date']).must_equal '2022-09-07'
  #   end

  #   it 'should be report error for an invalid episode_info' do
  #     TranSound::Service::AddPodcastInfo.new.call(
  #       episode_type: 'episode', episode_id: EPISODE_ID
  #     )

  #     get "/api/v1/podcast_info/episode/#{EPISODE_ID}/foobar"
  #     _(last_response.status).must_equal 404
  #     _(JSON.parse(last_response.body)['status']).must_include 'not'
  #   end

  #   it 'should be report error for an invalid episode' do
  #     TranSound::Service::AddPodcastInfo.new.call(
  #       episode_type: 'episode', episode_id: '2zplNaMpre0ASbFJV7OSSq'
  #     )

  #     get "/api/v1/podcast_info/episode/#{EPISODE_ID}/foobar"
  #     _(last_response.status).must_equal 404
  #     _(JSON.parse(last_response.body)['status']).must_include 'not'
  #   end
  # end

  # describe 'Add episodes route' do
  #   it 'should be able to add a episode' do
  #     post "api/v1/podcast_info/episode/#{EPISODE_ID}"

  #     _(last_response.status).must_equal 201

  #     episode = JSON.parse last_response.body
  #     _(episode['origin_id']).must_equal EPISODE_ID
  #     _(episode['type']).must_equal 'episode'
  #     _(episode['market']).must_equal MARKET

  #     episode = TranSound::Representer::Episode.new(
  #       TranSound::Representer::OpenStructWithLinks.new
  #     ).from_json last_response.body
  #     _(episode.links['self'].href).must_include 'http'
  #   end

  #   it 'should report error for invalid episode' do
  #     bad_episode_id = 'bad_episode_id'
  #     post "api/v1/podcast_info/episode/#{bad_episode_id}"

  #     _(last_response.status).must_equal 404

  #     response = JSON.parse(last_response.body)
  #     _(response['message']).must_include 'not'
  #   end
  # end

  # describe 'Get episodes list' do
  #   it 'should successfully return episode lists' do
  #     TranSound::Service::AddPodcastInfo.new.call(
  #       episode_type: 'episode', episode_id: EPISODE_ID
  #     )

  #     list = ["episode/#{EPISODE_ID}?market=#{MARKET}"]
  #     encoded_list = TranSound::Request::EncodedEpisodeList.to_encoded(list)

  #     get "/api/v1/podcast_info/episode?list=#{encoded_list}"
  #     _(last_response.status).must_equal 200

  #     response = JSON.parse(last_response.body)
  #     episodes = response['episodes']
  #     _(episodes.count).must_equal 1
  #     episode = episodes.first
  #     _(episode['origin_id']).must_equal EPISODE_ID
  #     _(episode['type']).must_equal 'episode'
  #     _(episode['market']).must_equal MARKET
  #   end

  #   it 'should return empty lists if none found' do
  #     list = ['djsafildafs;d/239eidj-fdjs']
  #     encoded_list = TranSound::Request::EncodedEpisodeList.to_encoded(list)

  #     get "/api/v1/podcast_info/episode?list=#{encoded_list}"
  #     _(last_response.status).must_equal 200

  #     response = JSON.parse(last_response.body)
  #     episodes = response['episodes']
  #     _(episodes).must_be_kind_of Array
  #     _(episodes.count).must_equal 0
  #   end

  #   it 'should return error if not list provided' do
  #     get '/api/v1/podcast_info/episode'

  #     _(last_response.status).must_equal 400

  #     response = JSON.parse(last_response.body)
  #     _(response['message']).must_include 'list'
  #   end
  # end

  describe 'View show route' do
    it 'should be able to view a show' do
      TranSound::Service::AddPodcastInfo.new.call(
        type: 'show', id: SHOW_ID
      )
      get "/api/v1/podcast_info/show/#{SHOW_ID}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[show]
      _(result['show']['origin_id']).must_equal SHOW_ID
      _(result['show']['type']).must_equal 'show'
      _(result['show']['market']).must_equal MARKET
      _(result['show']['description']).must_equal 'Kylie跟Ken 用雙語的對話包裝知識，用輕鬆的口吻胡說八道。我們閒聊也談正經事，讓生硬的國際大事變得鬆軟好入口；歡迎你加入這外表看似
      嘴砲，內容卻異於常人的有料聊天Bailingguo News。'
      _(result['show']['name']).must_equal '百靈果 News'
      _(result['show']['publisher']).must_equal 'Bailingguo News'
    end

    # it 'should be report error for an invalid show_info' do
    #   TranSound::Service::AddPodcastInfo.new.call(
    #     show_type: 'show', show_id: SHOW_ID
    #   )

    #   get "/api/v1/podcast_info/show/#{SHOW_ID}/foobar"
    #   _(last_response.status).must_equal 404
    #   _(JSON.parse(last_response.body)['status']).must_include 'not'
    # end

    # it 'should be report error for an invalid show' do
    #   TranSound::Service::AddPodcastInfo.new.call(
    #     show_type: 'show', show_id: '5Vv32KtHB3peVZ8TeacUty'
    #   )

    #   get "/api/v1/podcast_info/show/#{SHOW_ID}/foobar"
    #   _(last_response.status).must_equal 404
    #   _(JSON.parse(last_response.body)['status']).must_include 'not'
    # end
  end

  # describe 'Add shows route' do
  #   it 'should be able to add a show' do
  #     post "api/v1/podcast_info/show/#{SHOW_ID}"

  #     _(last_response.status).must_equal 201

  #     show = JSON.parse last_response.body
  #     _(show['origin_id']).must_equal SHOW_ID
  #     _(show['type']).must_equal 'show'
  #     _(show['market']).must_equal MARKET

  #     show = TranSound::Representer::SHOW.new(
  #       TranSound::Representer::OpenStructWithLinks.new
  #     ).from_json last_response.body
  #     _(show.links['self'].href).must_include 'http'
  #   end

  #   it 'should report error for invalid shows' do
  #     bad_show_id = 'bad_show_id'
  #     post "api/v1/podcast_info/show/#{bad_show_id}"

  #     _(last_response.status).must_equal 404

  #     response = JSON.parse(last_response.body)
  #     _(response['message']).must_include 'not'
  #   end
  # end

  # describe 'Get shows list' do
  #   it 'should successfully return show lists' do
  #     TranSound::Service::AddPodcastInfo.new.call(
  #       show_type: 'show', show_id: SHOW_ID
  #     )

  #     list = ["show/#{SHOW_ID}"]
  #     encoded_list = TranSound::Request::EncodedShowList.to_encoded(list)

  #     get "/api/v1/podcast_info/show?list=#{encoded_list}"
  #     _(last_response.status).must_equal 200

  #     response = JSON.parse(last_response.body)
  #     shows = response['shows']
  #     _(shows.count).must_equal 1
  #     show = shows.first
  #     _(show['origin_id']).must_equal SHOW_ID
  #     _(show['type']).must_equal 'show'
  #     _(show['market']).must_equal MARKET
  #   end

  #   it 'should return empty lists if none found' do
  #     list = ['bad_show_id']
  #     encoded_list = TranSound::Request::EncodedShowList.to_encoded(list)

  #     get "/api/v1/podcast_info/show?list=#{encoded_list}"
  #     _(last_response.status).must_equal 200

  #     response = JSON.parse(last_response.body)
  #     shows = response['shows']
  #     _(shows).must_be_kind_of Array
  #     _(shows.count).must_equal 0
  #   end

  #   it 'should return error if not list provided' do
  #     get '/api/v1/podcast_info/show'
  #     _(last_response.status).must_equal 400

  #     response = JSON.parse(last_response.body)
  #     _(response['message']).must_include 'list'
  #   end
  # end
end
