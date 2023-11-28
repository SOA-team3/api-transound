# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # retrieve podcast info
    class ViewPodcastInfo
      include Dry::Transaction

      step :ensure_watched_podcast_info
      step :retrieve_remote_podcast_info

      private

      # Steps

      def ensure_watched_podcast_info(input)
        requested = input[:requested]
        type = requested.type

        if type == 'episode'
          handle_ensure_watched_episode(requested, input)
        elsif type == 'show'
          handle_ensure_watched_show(requested, input)
        end
      end

      def retrieve_remote_podcast_info(input)
        request = input[:requested]
        type = request.type

        if type == 'episode'
          handle_retrieve_remote_episode(request, input)
        elsif type == 'show'
          handle_retrieve_remote_show(request, input)
        end
      rescue StandardError
        Failure('Having trouble accessing the database')
      end

      def handle_ensure_watched_episode(requested, input)
        if input[:watched_list][:episode_id].include? requested.id
          Success(input)
        else
          Failure('Please first request this episode to be added to your list')
        end
      end

      def handle_ensure_watched_show(requested, input)
        if input[:watched_list][:show_id].include? requested.id
          Success(input)
        else
          Failure('Please first request this show to be added to your list')
        end
      end

      def handle_retrieve_remote_episode(request, input)
        input[:episode] = Repository::For.klass(Entity::Episode).find_podcast_info(
          request.id
        )
        input[:episode] ? Success(input) : Failure('Episode not found')
      end

      def handle_retrieve_remote_show(request, input)
        input[:show] = Repository::For.klass(Entity::Show).find_podcast_info(
          request.id
        )
        input[:show] ? Success(input) : Failure('Show not found')
      end
    end
  end
end
