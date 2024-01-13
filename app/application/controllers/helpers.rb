# frozen_string_literal: true

module TranSound
  module Request
    # Application value for the path of a requested project
    class PodcastInfoRequestPath
      def initialize(type, id)
        @type = type
        @id = id
      end

      attr_reader :type, :id
    end
  end
end
