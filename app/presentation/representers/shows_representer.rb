# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'show_representer'

module TranSound
  module Representer
    # Represents list of shows for API output
    class ShowsList < Roar::Decorator
      include Roar::JSON

      collection :shows, extend: Representer::Show,
                         class: Representer::OpenStructWithLinks
    end
  end
end
