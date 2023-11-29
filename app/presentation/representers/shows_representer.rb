# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'member_representer'

# Represents essential Repo information for API output
module TranSound
  module Representer
    # Represent a show entity as Json
    class Show < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :description
      property :images
      property :name
      property :publisher
      property :type
      property :show_url

      link :self do
        "#{ENV.fetch('API_HOST', nil)}/api/v1/shows/#{show_type}/#{show_id}"
      end

      private

      def show_type
        represented.type
      end

      def show_id
        represented.id
      end
    end
  end
end
