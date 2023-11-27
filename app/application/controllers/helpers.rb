# frozen_string_literal: true

module TranSound
  module RouteHelpers
    # Application value for the path of a requested project
    class PodcastInfoRequestPath
      def initialize(type, id, _request)
        @type = type
        @id = id
      end

      attr_reader :type, :id
    end
  end
end
