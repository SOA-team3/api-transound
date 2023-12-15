# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'episode_representer'

module TranSound
  module Representer
    # Represents episodes summary
    class EpisodesView < Roar::Decorator
      include Roar::JSON

      property :episodes, extend: Representer::Episode,
                          class: OpenStruct
    end
  end
end
