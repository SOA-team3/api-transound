# frozen_string_literal: true

require 'dry/transaction'

TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')

module TranSound
  module Service
    # Transaction to store episode from Spotify API to database
    class AddPodcastInfo
      include Dry::Transaction

      step :find_podcast_info
      step :store_podcast_info

      private

      DB_ERR_MSG = 'Having trouble accessing the database (Might have same data in database)'

      def find_podcast_info(input)
        @type = input[:type]
        if @type == 'episode'
          handle_find_episode(input)
        elsif @type == 'show'
          handle_find_show(input)
        end
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_podcast_info(input)
        if @type == 'episode'
          handle_store_episode(input)
        elsif @type == 'show'
          handle_store_show(input)
        end
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # following are support methods that other services could use

      def handle_find_episode(input)
        if (episode = episode_in_database(input))
          input[:local_episode] = episode
        else
          input[:remote_episode] = episode_from_spotify(input)
        end
        Success(input)
      end

      def handle_find_show(input)
        if (show = show_in_database(input))
          input[:local_show] = show
        else
          input[:remote_show] = show_from_spotify(input)
        end
        Success(input)
      end

      def handle_store_episode(input)
        episode =
          if (podcast_info = input[:remote_episode])
            Repository::For.entity(podcast_info).create(podcast_info)
          else
            input[:local_episode]
          end
        Success(Response::ApiResult.new(status: :created, message: episode))
      end

      def handle_store_show(input)
        show =
          if (podcast_info = input[:remote_show])
            Repository::For.entity(podcast_info).create(podcast_info)
          else
            input[:local_show]
          end
        Success(Response::ApiResult.new(status: :created, message: show))
      end

      def episode_from_spotify(input)
        temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                        App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        TranSound::Podcast::EpisodeMapper
          .new(temp_token)
          .find("#{@type}s", input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that episode on Spotify'
      end

      def show_from_spotify(input)
        temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                        App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        TranSound::Podcast::ShowMapper
          .new(temp_token)
          .find("#{@type}s", input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that show on Spotify'
      end

      def episode_in_database(input)
        Repository::For.klass(Entity::Episode)
          .find_podcast_info(input[:id])
      end

      def show_in_database(input)
        Repository::For.klass(Entity::Show)
          .find_podcast_info(input[:id])
      end
    end
  end
end
