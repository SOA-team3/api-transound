# frozen_string_literal: false

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
            id: nil,
            origin_id:,
            description:,
            images:,
            name:,
            publisher:,
            type:,
            show_url:
            # episodes:
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

        def episodes
          @show['episodes']
        end

        def show_url
          "https://open.spotify.com/#{type}/#{origin_id}"
        end
      end
    end
  end
end
