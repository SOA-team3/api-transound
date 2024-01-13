# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'show_representer'

module TranSound
  module Representer
    # Represents shows summary
    class ShowsView < Roar::Decorator
      include Roar::JSON

      property :shows, extend: Representer::Show,
                       class: OpenStruct
    end
  end
end
