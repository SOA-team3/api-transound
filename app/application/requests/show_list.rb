# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module TranSound
  module Request
    # Show list request parser
    class EncodedShowList
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
        puts 'EncodedShowList initialized'
      end

      # Use in API to parse incoming list requests
      def call
        Success(
          # JSON.parse(decode(@params['list']))
          @params
        )
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: bad_request,
            message: 'Show list not found'
          )
        )
      end

      # Decode params
      def decode(param)
        Base64.urlsafe_decode64(param)
      end

      # Client App will encode params to send as a string
      # - Use this method to create encoded params for testing
      def self.to_encoded(list)
        Base64.urlsafe_decode64(list.to_json)
      end

      # Use in tests to create a ShowList object from a list
      def self.to_request(list)
        EncodedShowList.new('list' => to_encoded(list))
      end
    end
  end
end
