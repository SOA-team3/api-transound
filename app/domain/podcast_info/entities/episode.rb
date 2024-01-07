# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TranSound
  module Entity
    # Domain entity for any podcast episode
    class Episode < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :origin_id, Strict::String
      attribute :description, Strict::String
      attribute :images, Strict::String # Strict::Array
      attribute :language, Strict::String
      attribute :name, Strict::String
      attribute :release_date, Strict::String # Date Format
      attribute :type, Strict::String
      attribute :episode_url, Strict::String
      attribute :episode_mp3_url, Strict::String
      attribute :podcast_length, Strict::Integer
      attribute :transcript, Strict::String
      attribute :sentence_segments, Strict::String
      attribute :translation, Strict::String
      attribute :difficulty_score, Strict::Float
      attribute :word_dict, Strict::String
      attribute :difficult_words, Strict::String
      attribute :moderate_words, Strict::String
      attribute :easy_words, Strict::String

      def to_attr_hash
        # to_hash.reject { |key, _| %i[id owner contributors].include? key }
        to_hash.except(:id)
      end
    end
  end
end
