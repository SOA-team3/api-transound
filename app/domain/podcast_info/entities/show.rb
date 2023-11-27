# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TranSound
  module Entity
    # Domain entity for any podcast shows
    class Show < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :origin_id, Strict::String
      attribute :description, Strict::String
      attribute :images, Strict::String # Strict::Array
      attribute :name, Strict::String
      attribute :publisher, Strict::String
      attribute :type, Strict::String
      attribute :show_url, Strict::String
      # attribute :episodes, Strict::Hash

      def show_num?
        top > 10
      end

      def to_attr_hash
        to_hash.except(:id, :episodes)
      end
    end
  end
end
