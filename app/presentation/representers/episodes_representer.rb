# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'episode_representer'

module TranSound
  module Representer
    # Represents list of episodes for API output
    class EpisodesList < Roar::Decorator
      include Roar::JSON

      collection :episodes, extend: Representer::Episode,
                            class: Representer::OpenStructWithLinks
    end
  end
end
