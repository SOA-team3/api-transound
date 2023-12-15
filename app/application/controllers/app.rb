# frozen_string_literal: true

require 'roda'

module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :caching
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    # use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    route do |routing|
      response['Content-Type'] = 'application/json'

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
              puts TEMP_TOKEN_CONFIG

              puts "api, app.rb: #{type}"
              puts "api, app.rb: #{id}"

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
              result = Service::AddPodcastInfo.new.call(
                type:, id:
              )

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

            routing.is do
              # GET /projects?list={base64_json_array_of_project_fullnames}
              routing.get do
                if type == 'episode'
                  list_req = Request::EncodedEpisodeList.new(routing.params)
                  result = Service::ListEpisodes.new.call(list_request: list_req)
                elsif type == 'show'
                  list_req = Request::EncodedShowList.new(routing.params)
                  result = Service::ListShows.new.call(list_request: list_req)
                end

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code

                puts "app.rb: #{result.value}"

                if type == 'episode'
                  Representer::EpisodesList.new(result.value!.message).to_json
                elsif type == 'show'
                  Representer::ShowsList.new(result.value!.message).to_json
                end
              end
            end
          end
        end
      end
    end
  end
end
