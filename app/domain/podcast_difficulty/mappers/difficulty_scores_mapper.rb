# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative '../../../infrastructure/gateways/word_difficulty'

module TranSound
  module Mapper
    # Difficulty scores parsing and reporting services?
    class DifficultyScores
      def initialize(transcript)
        @transcript = transcript
      end

      def word_split(sentence)
        sentence.downcase.gsub(/[^a-z\s]/, '').split
      end

      # Difficulty-level calculated per word and return a word-difficulty-dict
      # Note: 2 min podcast take 45 min to analyse
      def words_difficulty_calculate(word_array)
        words_difficulty_dict = {}
        word_array.each do |word|
          word_difficulty = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficulty
            .new(word).calculate_word_difficulty
          words_difficulty_dict[word] = word_difficulty
        end
        words_difficulty_dict
      end

      # Return a word-difficulty-dict by input transcript
      def words_difficulty_dict_create(transcript)
        json_string = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict
          .new(transcript).create_word_difficulty_dict
        # Handling Abbreviation situation e.g."i'm"，transform into "i"m"
        # Replace single quotes with double quotes except for apostrophes in contractions
        modified_string = json_string.gsub("'", '"').gsub('": "', '": "').gsub('": "', '": "')
        JSON.parse(modified_string)
      rescue JSON::ParserError => e
        puts "JSON parsing error: #{e.message}"
        {}
      end
    end
  end
end
