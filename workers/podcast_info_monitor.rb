# frozen_string_literal: true

module EpisodeInfo
  class PodcastInfoMonitor
    EPISODE_PROGRESS = {
      'STARTED' => 15,
      'mapper' => 80,
      'FINISHED' => 100
    }

    def self.starting_percent
      EPISODE_PROGRESS['STARTED'].to_s
    end

    def self.mapper_done
      EPISODE_PROGRESS['mapper'].to_s
    end

    def self.finished_percent
      EPISODE_PROGRESS['FINISHED'].to_s
    end
  end
end
