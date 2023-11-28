# frozen_string_literal: true

require_relative 'episode'

module Views
  # View for a a list of episode entities
  class EpisodesList
    def initialize(episodes)
      @episodes = episodes.map.with_index { |episode, index| Episode.new(episode, index) }
    end

    def each(&show)
      @episodes.each do |episode|
        show.call episode
      end
    end

    def any?
      @episodes.any?
    end
  end
end
