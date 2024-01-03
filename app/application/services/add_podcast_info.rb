# frozen_string_literal: true

require 'dry/transaction'

module TranSound
  module Service
    # Transaction to store episode from Spotify API to database
    # class AddEpisode
    #   include Dry::Transaction

    #   step :find_episode
    #   step :request_episode_worker
    #   step :store_episode

    #   private

    #   TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')
    #   DB_ERR_MSG = 'Having trouble accessing the database (Might have same data in database)'
    #   PROCESSING_MSG_EP = 'Processing the episode request'
    #   PROCESS_ERR_EP = 'Could not process this episode'

    #   def find_episode(input)
    #     if (episode = episode_in_database(input))
    #       input[:local_episode] = episode
    #     end
    #     Success(input)
    #   rescue StandardError => e
    #     Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
    #   end

    #   def request_episode_worker(input)
    #     puts 'add_podcast_info, request_episode_worker'
    #     config = App.config

    #     TranSound::Podcast::Api::Token.new(config, config.spotify_Client_ID,
    #                                        config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get

    #     # json = Representer::Episode.new(Response::Episode.new(origin_id:)).to_json

    #     input[:remote_episode] =
    #       Messaging::Queue.new(config.ADD_PODCAST_INFO_QUEUE_URL, config).send(input[:id])

    #     Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG_EP))
    #   rescue StandardError
    #     # log_error(e)
    #     Failure(Response::ApiResult.new(status: :internal_error, message: PROCESS_ERR_EP))
    #   end

    #   def store_episode(input)
    #     episode =
    #       if (podcast_info = input[:remote_episode])
    #         Repository::For.entity(podcast_info).create(podcast_info)
    #       else
    #         input[:local_episode]
    #       end
    #     Success(Response::ApiResult.new(status: :created, message: episode))
    #   rescue StandardError => e
    #     App.logger.error e.backtrace.join("\n")
    #     Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
    #   end

    #   def episode_in_database(input)
    #     Repository::For.klass(Entity::Episode)
    #       .find_podcast_info(input[:id])
    #   end
    # end

    # Transaction to store show from Spotify API to database
    class AddShow
      include Dry::Transaction

      step :find_show
      step :store_show

      private

      TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')
      DB_ERR_MSG = 'Having trouble accessing the database (Might have same data in database)'
      PROCESSING_MSG_SH = 'Processing the show request'
      PROCESS_ERR_SH = 'Could not process this show'

      def find_show(input)
        if (show = show_in_database(input))
          input[:local_show] = show
        else
          input[:remote_show] = show_from_spotify(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_show(input)
        show =
          if (podcast_info = input[:remote_show])
            Repository::For.entity(podcast_info).create(podcast_info)
          else
            input[:local_show]
          end
        Success(Response::ApiResult.new(status: :created, message: show))
      end

      def show_from_spotify(input)
        config = App.config
        temp_token = TranSound::Podcast::Api::Token.new(config, config.spotify_Client_ID,
                                                        config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        TranSound::Podcast::ShowMapper
          .new(temp_token)
          .find('shows', input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that show on Spotify'
      end

      def show_in_database(input)
        Repository::For.klass(Entity::Show)
          .find_podcast_info(input[:id])
      end
    end

    class AddEpisode
      include Dry::Transaction

      step :find_episode
      step :store_episode

      private

      DB_ERR_MSG = 'Having trouble accessing the database (Might have same data in database)'

      def find_episode(input)
        if (episode = episode_in_database(input))
          input[:local_episode] = episode
        else
          input[:remote_episode] = episode_from_spotify(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_episode(input)
        episode =
          if (podcast_info = input[:remote_episode])
            Repository::For.entity(podcast_info).create(podcast_info)
          else
            input[:local_episode]
          end
        Success(Response::ApiResult.new(status: :created, message: episode))
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # following are support methods that other services could use

      def episode_from_spotify(input)
        temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                        App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get
        TranSound::Podcast::EpisodeMapper
          .new(temp_token)
          .find("#{@type}s", input[:id], 'TW')
      rescue StandardError
        raise 'Could not find that episode on Spotify'
      end

      def episode_in_database(input)
        Repository::For.klass(Entity::Episode)
          .find_podcast_info(input[:id])
      end
    end
  end
end
