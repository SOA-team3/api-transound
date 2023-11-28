# frozen_string_literal: true

require_relative 'show'

module Views
  # View for a a list of show entities
  class ShowsList
    def initialize(shows)
      @shows = shows.map.with_index { |show, index| Show.new(show, index) }
    end

    def each(&show)
      @shows.each do |shoow| # typo on purpose
        show.call shoow
      end
    end

    def any?
      @shows.any?
    end
  end
end
