# frozen_string_literal: true

module TranSound
  module Entity
    # Entity for an array of sentences from a transcription
    class LearningScores
      HARD_LEVEL_WEIGHT = 2

      attr_reader :lines, :translate_times

      def initialize(lines:, translate_times:)
        @lines = lines
        @translate_times = translate_times
      end
    end
  end
end
