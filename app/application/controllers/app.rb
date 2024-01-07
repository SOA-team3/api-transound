# frozen_string_literal: true


require 'roda'
require 'base64'
require 'json'


TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')


module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :caching
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    #$TYPE = ''
    # use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)


    route do |routing|
      response['Content-Type'] = 'application/json'
      # Podcast::DownloaderUtils::NLTKPretrainedModel.new.download

      # GET /
      routing.root do
        message = "TranSound API v1 at /api/v1/ in #{App.environment} mode"


        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )


        response.status = result_response.http_status_code
        result_response.to_json
      end


      routing.on 'api/v1' do
        routing.on 'podcast_info' do
          routing.on String, String do |type, id|
            # GET /episode/id or /show/id
            routing.get do
              response.cache_control public: true, max_age: 400


              TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                 App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
              puts "api, app.rb, temp token: #{TEMP_TOKEN_CONFIG}"


              path_request = Request::PodcastInfoPath.new(
                type, id, request
              )


              puts "api, app.rb: #{path_request.inspect}"


              result = Service::ViewPodcastInfo.new.call(
                requested: path_request
              )


              puts "api, app.rb, success: #{result}"


              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end


              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code


              if type == 'episode'
                Representer::EpisodesView.new(
                  result.value!.message
                ).to_json
              elsif type == 'show'
                Representer::ShowsView.new(
                  result.value!.message
                ).to_json
              end
            end


            # POST /episode/id or /show/id
            routing.post do
              if type == 'episode'
                request_id = [request.env, request.path, Time.now.to_f].hash
                #$TYPE = 'episode'
                result = Service::AddEpisode.new.call(
                  type:, id:,
                  request_id:
                )
              elsif type == 'show'
                #$TYPE = 'show'
                result = Service::AddShow.new.call(
                  type:, id:
                )
              end


              puts "api, app.rb, post: #{result.inspect}"


              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end


              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              if type == 'episode'
                Representer::Episode.new(result.value!.message).to_json
              elsif type == 'show'
                Representer::Show.new(result.value!.message).to_json
              end
            end
          end


          routing.is do
            # GET /projects?list={base64_json_array_of_project_fullnames}
            routing.get do


              puts 'routing.get start'
              # decode
              params = routing.params
              decode64 = Base64.urlsafe_decode64(params['list'])
              listwtype = JSON.parse(decode64)
              puts "routing.get, listwtype: #{listwtype}"


              if listwtype[0] == "episode"
                list = listwtype[1..]
                puts "routing.get, episode: #{list}"
                list_req = Request::EncodedEpisodeList.new(list)
                result = Service::ListEpisodes.new.call(list_request: list_req)
                puts "routing.get, episode result: #{result}"
              elsif listwtype[0] == "show"
                list = listwtype[1..]
                puts "routing.get, show: #{list}"
                list_req = Request::EncodedShowList.new(list)
                result = Service::ListShows.new.call(list_request: list_req)
                puts "routing.get, show result: #{result}"


              end


              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end


              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code


              if listwtype[0] == "episode"
                Representer::EpisodesList.new(result.value!.message).to_json
              elsif listwtype[0] == "show"
                Representer::ShowsList.new(result.value!.message).to_json
              end
            end
          end
        end
      end
    end
  end
end



