# frozen_string_literal: true

require_relative 'podcast_info_worker'

worker = EpisodeWorker.new
worker.perform(nil, '2zplNaMpre0ASbFJV7OSSq')
