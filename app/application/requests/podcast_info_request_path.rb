# frozen_string_literal: true

module TranSound
  module RouteHelpers
    # Application value for the path of a requested project
    class PodcastInfoPath
      def initialize(type, id)
        @type = type
        @id = id
      end

      attr_reader :type, :id
    end
  end
end
