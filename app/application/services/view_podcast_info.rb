# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # retrieve podcast info
    class ViewPodcastInfo
      include Dry::Transaction

      step :retrieve_remote_podcast_info
      step :view_podcast_info_list

      private

      NO_POD_ERR = 'Podcast Info not found'
      DB_ERR = 'Having trouble accessing the database'
      NO_VIEW_ERR = 'Could not find that podcast info'

      # Steps

      def retrieve_remote_podcast_info(input)
        requested = input[:requested]
        type = requested.type
        if type == 'episode'
          handle_retrieve_remote_episode(requested, input)
        elsif type == 'show'
          handle_retrieve_remote_show(requested, input)
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def handle_retrieve_remote_episode(requested, input)
        input[:episode] = Repository::For.klass(Entity::Episode).find_podcast_info(
          requested.id
        )
        if input[:episode]
          Success(input)
        else
          Failure(Response::ApiResult.new(
                    status: :not_found, message: NO_POD_ERR
                  ))
        end
      end

      def handle_retrieve_remote_show(requested, input)
        input[:show] = Repository::For.klass(Entity::Show).find_podcast_info(
          requested.id
        )

        if input[:show]
          Success(input)
        else
          Failure(Response::ApiResult.new(
                    status: :not_found, message: NO_POD_ERR
                  ))
        end
      end

      def view_podcast_info_list(input)
        requested = input[:requested]
        type = requested.type

        if type == 'episode'
          podcast_info = Response::EpisodesView.new(input[:episode])
        elsif type == 'show'
          podcast_info = Response::ShowsView.new(input[:show])
        end

        Success(Response::ApiResult.new(status: :ok, message: podcast_info))
      rescue StandardError
        # App.logger.error "Could not find: #{full_request_path(input)}"
        Failure(Response::ApiResult.new(status: :not_found, message: NO_VIEW_ERR))
      end
    end
  end
end
