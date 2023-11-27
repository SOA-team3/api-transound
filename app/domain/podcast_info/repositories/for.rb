# frozen_string_literal: true

require_relative 'episodes'
require_relative 'shows'

module TranSound
  module Repository
    # Finds the right repository for an entity object or class
    module For
      ENTITY_REPOSITORY = {
        Entity::Episode => Episodes,
        Entity::Show => Shows
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
