# frozen_string_literal: true

require 'dry-validation'

module TranSound
  module Forms
    # Form validation for Spotify episode or show URL
    class NewPodcastInfo < Dry::Validation::Contract
      URL_REGEX = %r{https://open\.spotify\.com/(show|episode)/[a-zA-Z0-9]+}
      MSG_INVALID_URL = 'is an invalid address for a Spotify podcast episode or show'

      params do
        required(:spotify_url).filled(:string)
      end

      rule(:spotify_url) do
        key.failure(MSG_INVALID_URL) unless URL_REGEX.match?(value)
      end
    end
  end
end
