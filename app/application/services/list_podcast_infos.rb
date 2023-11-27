# frozen_string_literal: true

require 'dry/monads'

module TranSound
  module Service
    DB_ERR = 'Could not access database'

    # Retrieves array of all listed episode entities
    class ListEpisodes
      include Dry::Transaction

      step :validate_list
      step :retrieve_episodes

      private

      # Expects list of movies in input[:list_request]
      def validate_list(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def retrieve_episodes(_input)
        Repository::For.klass(Entity::Episode)
          .find_podcast_infos(episodes_list)
          .then { |episodes| Response::EpisodesList.new(episodes) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end

    # Retrieves array of all listed show entities
    class ListShows
      include Dry::Transaction

      step :validate_list
      step :retrieve_shows

      private

      # Expects list of movies in input[:list_request]
      def validate_list(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def retrieve_shows(_input)
        Repository::For.klass(Entity::Show)
          .find_podcast_infos(shows_list)
          .then { |shows| Response::ShowsList.new(shows) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
