# frozen_string_literal: false

require 'json'

module TranSound
  module Podcast
    # Data Mapper: Podcast episode -> Episode entity
    class ShowMapper
      def initialize(token, gateway_class = Podcast::Api)
        @spot_token = token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@spot_token)
      end

      def find(type, id, market)
        data = @gateway.show_data(type, id, market)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @spot_token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @show = data
          @spot_token = token
          @gateway_class = gateway_class
        end

        def build_entity
          TranSound::Entity::Show.new(
            id: nil, origin_id:, description:,
            images:,
            name:,
            publisher:,
            type:,
            show_url:,
            recent_episodes:
          )
        end

        def origin_id
          @show['id']
        end

        def description
          @show['description']
        end

        def images
          # @show['images'] ## if images-type == Array
          @show['images'][0]['url']
        end

        def name
          @show['name']
        end

        def publisher
          @show['publisher']
        end

        def type
          @show['type']
        end

        def show_url
          "https://open.spotify.com/#{type}/#{origin_id}"
        end

        def recent_episodes
          n = 5
          recent_episodes = @show['episodes']['items'][...n]
          recent_n_episodes = recent_episodes.map.with_index do |episode, _i|
            {
              'release_date' => episode['release_date'],
              'name' => episode['name'],
              'description' => episode['description'],
              'language' => episode['language']
            }
          end

          # Transfer Hash-Array into String by Json module
          json_string = JSON.generate(recent_n_episodes)
          # puts "show_mapper json_string.class: #{json_string.class}"
          # json_string
        end
      end
    end
  end
end

# test
# require_relative '../../../infrastructure/gateways/podcast_api'
# require 'yaml'
# config = YAML.safe_load_file('/home/brian/SOA_assignment/SOA2023_transound/monolith-transound/config/temp_token.yml')
# temp_token = config['spotify_temp_token']
# show_id = '5Vv32KtHB3peVZ8TeacUty'
# show = TranSound::Podcast::ShowMapper.new(temp_token).find('shows', show_id, 'TW')
# puts "Show.episode:\n#{show.episodes}"