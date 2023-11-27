# frozen_string_literal: true

require 'dry/monads'

module TranSound
  module Service
    # Retrieves array of all listed episode entities
    class ListEpisodes
      include Dry::Monads::Result::Mixin

      def call(episodes_list)
        # Load previously viewed episodes
        episodes = Repository::For.klass(Entity::Episode)
          .find_podcast_infos(episodes_list)

        Success(episodes)
      rescue StandardError
        Failure('Could not access database')
      end
    end

    # Retrieves array of all listed show entities
    class ListShows
      include Dry::Monads::Result::Mixin

      def call(shows_list)
        shows = Repository::For.klass(Entity::Show)
          .find_podcast_infos(shows_list)

        Success(shows)
      rescue StandardError
        Failure('Could not access database')
      end
    end
  end
end
