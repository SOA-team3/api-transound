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
        episode_type: EPISODE_TYPE, episode_id: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder project]
      _(result['project']['name']).must_equal EPISODE_ID
      _(result['project']['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(result['project']['contributors'].count).must_equal 3
      _(result['folder']['path']).must_equal ''
      _(result['folder']['subfolders'].count).must_equal 10
      _(result['folder']['line_count']).must_equal 1450
      _(result['folder']['base_files'].count).must_equal 2
    end

    it 'should be able to appraise a project subfolder' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/spec"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder project]
      _(result['project']['name']).must_equal EPISODE_ID
      _(result['project']['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(result['project']['contributors'].count).must_equal 3
      _(result['folder']['path']).must_equal 'spec'
      _(result['folder']['subfolders'].count).must_equal 1
      _(result['folder']['line_count']).must_equal 151
      _(result['folder']['base_files'].count).must_equal 3
    end

    it 'should be report error for an invalid subfolder' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end

    it 'should be report error for an invalid project' do
      TranSound::Service::AddProject.new.call(
        owner_name: '0u9awfh4', EPISODE_ID: 'q03g49sdflkj'
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Add projects route' do
    it 'should be able to add a project' do
      post "api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}"

      _(last_response.status).must_equal 201

      project = JSON.parse last_response.body
      _(project['name']).must_equal EPISODE_ID
      _(project['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE

      proj = TranSound::Representer::Project.new(
        TranSound::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      _(proj.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid projects' do
      post 'api/v1/projects/0u9awfh4/q03g49sdflkj'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get projects list' do
    it 'should successfully return project lists' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      list = ["#{EPISODE_TYPE}/#{EPISODE_ID}"]
      encoded_list = TranSound::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/projects?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects.count).must_equal 1
      project = projects.first
      _(project['name']).must_equal EPISODE_ID
      _(project['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(project['contributors'].count).must_equal 3
    end

    it 'should return empty lists if none found' do
      list = ['djsafildafs;d/239eidj-fdjs']
      encoded_list = TranSound::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/projects?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects).must_be_kind_of Array
      _(projects.count).must_equal 0
    end

    it 'should return error if not list provided' do
      get '/api/v1/projects'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end

  describe 'Appraise project folder route' do
    it 'should be able to appraise a project folder' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder project]
      _(result['project']['name']).must_equal EPISODE_ID
      _(result['project']['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(result['project']['contributors'].count).must_equal 3
      _(result['folder']['path']).must_equal ''
      _(result['folder']['subfolders'].count).must_equal 10
      _(result['folder']['line_count']).must_equal 1450
      _(result['folder']['base_files'].count).must_equal 2
    end

    it 'should be able to appraise a project subfolder' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/spec"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result.keys.sort).must_equal %w[folder project]
      _(result['project']['name']).must_equal EPISODE_ID
      _(result['project']['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(result['project']['contributors'].count).must_equal 3
      _(result['folder']['path']).must_equal 'spec'
      _(result['folder']['subfolders'].count).must_equal 1
      _(result['folder']['line_count']).must_equal 151
      _(result['folder']['base_files'].count).must_equal 3
    end

    it 'should be report error for an invalid subfolder' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end

    it 'should be report error for an invalid project' do
      TranSound::Service::AddProject.new.call(
        owner_name: '0u9awfh4', EPISODE_ID: 'q03g49sdflkj'
      )

      get "/api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}/foobar"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Add projects route' do
    it 'should be able to add a project' do
      post "api/v1/projects/#{EPISODE_TYPE}/#{EPISODE_ID}"

      _(last_response.status).must_equal 201

      project = JSON.parse last_response.body
      _(project['name']).must_equal EPISODE_ID
      _(project['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE

      proj = TranSound::Representer::Project.new(
        TranSound::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      _(proj.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid projects' do
      post 'api/v1/projects/0u9awfh4/q03g49sdflkj'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get projects list' do
    it 'should successfully return project lists' do
      TranSound::Service::AddProject.new.call(
        owner_name: EPISODE_TYPE, EPISODE_ID: EPISODE_ID
      )

      list = ["#{EPISODE_TYPE}/#{EPISODE_ID}"]
      encoded_list = TranSound::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/projects?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects.count).must_equal 1
      project = projects.first
      _(project['name']).must_equal EPISODE_ID
      _(project['owner']['EPISODE_TYPE']).must_equal EPISODE_TYPE
      _(project['contributors'].count).must_equal 3
    end

    it 'should return empty lists if none found' do
      list = ['djsafildafs;d/239eidj-fdjs']
      encoded_list = TranSound::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/projects?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects).must_be_kind_of Array
      _(projects.count).must_equal 0
    end

    it 'should return error if not list provided' do
      get '/api/v1/projects'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end

end