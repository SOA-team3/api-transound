# frozen_string_literal: true

require 'roda'

module TranSound
  # Application inherits from Roda
  class App < Roda

    plugin :halt
    plugin :flash
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
              path_request = Request::PodcastInfoPath.new(
                type, id
              )

              result = Service::ViewPodcastInfo.new.call(
                requested: path_request
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
            end

            # POST /episode/id or /show/id
            routing.post do
              result = Service::AddPodcastInfo.new.call(
                type:, id:
              )

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
        end
      end
    end
  end
end
