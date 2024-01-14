# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative '../../../infrastructure/gateways/word_difficulty'

module TranSound
  module Mixins
    # line credit calculation methods
    module DifficultyCalculator
      def dict_filter(dict, level)
        if %w[easy moderate difficult unclassified].include?(level)
          dict.select { |_key, value| value == level }
        else
          {}
        end
      end
    end
  end
end
