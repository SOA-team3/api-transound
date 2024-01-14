# frozen_string_literal: true

require_relative '../lib/difficulty_calculator'
require_relative '../mappers/difficulty_scores_mapper'

module TranSound
  module Entity
    # Entity for different scorings of a transcript
    class DifficultyScores
      include Mixins::DifficultyCalculator
      include Mapper

      attr_reader :transcript

      def initialize(transcript)
        @transcript = transcript
        @t = TranSound::Mapper::DifficultyScores.new(@transcript)
      end

      def words_array
        @t.word_split(@transcript)
      end

      def words_difficulty_dict_by_words_array
        @t.words_difficulty_calculate(words_array)
      end

      def words_difficulty_dict_by_transcript
        @t.words_difficulty_dict_create(@transcript)
      end
    end
  end
end

# test
# TEST_TRANSCRIPT = YAML.safe_load_file('app/domain/podcast_difficulty/lib/test_transcript.yml')
# TEST_TRANSCRIPT = "I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically.
# There's a new baby every Christmas.
# It's one of those families.
# I go home, it's crowded.
# I go, oh, oh, who's this?
# Oh, yours?
# Oh, well done.
# I don't know him, I don't know her.
# You know what I mean?
# It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right?
# But to keep it secret.
# So they all love me, right?
# And I'm not doing a will, so my funeral is going to be a fucking bloodbath."

# difficulty_score = TranSound::Entity::DifficultyScores.new(transcript: TEST_TRANSCRIPT)
# puts "difficulty_score transcript: #{difficulty_score.transcript}"
# words_difficulty_dict = difficulty_score.words_difficulty_dict_by_transcript
# puts "difficulty_score words_difficulty_dict: #{words_difficulty_dict}"
# puts "dict_class: #{words_difficulty_dict.class}"
# puts "difficulty_score dict_filter: #{difficulty_score.dict_filter(words_difficulty_dict, 'difficult')}"
