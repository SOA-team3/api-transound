# frozen_string_literal: true

module TranSound
  module Request
    # Application value for the path of a requested project
    class PodcastInfoPath
      def initialize(type, id, request)
        @type = type
        @id = id
        @request = request
      end

      attr_reader :type, :id
    end
  end
end
