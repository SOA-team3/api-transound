require_relative 'podcast_info_worker.rb'

worker = EpisodeWorker.new
worker.perform(nil, '2zplNaMpre0ASbFJV7OSSq')