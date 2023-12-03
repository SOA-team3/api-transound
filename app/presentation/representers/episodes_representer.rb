# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module TranSound
  module Representer
    # Represent a episode entity as Json
    class Episode < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :origin_id
      property :description
      property :images
      property :language
      property :name
      property :release_date
      property :type
      property :episode_url
      property :episode_mp3_url
      property :transcript
      property :translation

      link :self do
        "#{ENV.fetch('API_HOST', nil)}/api/v1/podcast_info/#{episode_type}/#{episode_id}"
      end

      private

      def episode_type
        represented.type
      end

      def episode_id
        represented.id
      end
    end
  end
end
