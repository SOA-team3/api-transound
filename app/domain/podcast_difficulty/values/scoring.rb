# frozen_string_literal: true

require_relative '../lib/difficulty_calculator'
require_relative '../entities/difficulty_scores'
require 'yaml'

module TranSound
  module Value
    # Value of Podcast's difficulty scoring
    class Scoring
      DIFFICULT_WEIGHT = 3
      MODERATE_WEIGHT = 2
      EASY_WEIGHT = 1

      def initialize(words_difficulty_dict)
        @words_difficulty_dict = words_difficulty_dict
        @transcript = YAML.safe_load_file('app/domain/podcast_difficulty/lib/test_transcript.yml')
        @difficulty_score = TranSound::Entity::DifficultyScores.new(transcript: @transcript)
      end

      def difficult_dict
        @difficulty_score.dict_filter(@words_difficulty_dict,  'difficult')
      end

      def moderate_dict
        @difficulty_score.dict_filter(@words_difficulty_dict,  'moderate')
      end

      def easy_dict
        @difficulty_score.dict_filter(@words_difficulty_dict,  'easy')
      end

      def unclassified_dict
        @difficulty_score.dict_filter(@words_difficulty_dict,  'unclassified')
      end

      def podcast_difficult_score
        total_difficulty_length = @words_difficulty_dict.length - unclassified_dict.length
        puts "total_difficulty_length: #{total_difficulty_length}"
        difficulty_weight = (difficult_dict.length * DIFFICULT_WEIGHT) + (moderate_dict.length * MODERATE_WEIGHT) + (easy_dict.length * EASY_WEIGHT)
        puts "difficulty_weight: #{difficulty_weight}"
        100 * difficulty_weight.to_f / (total_difficulty_length * DIFFICULT_WEIGHT)
      end
    end
  end
end

# test
# temp_dict_file_path = 'app/domain/podcast_difficulty/lib/temp_word_difficulty_dict.yml'
# words_difficulty_dict = YAML.safe_load_file(temp_dict_file_path).to_h
# puts TranSound::Value::Scoring.new(words_difficulty_dict).podcast_difficult_score
