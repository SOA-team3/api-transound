# frozen_string_literal: true

require 'sequel'

module TranSound
  module Database
    # Object Relational Mapper for Episode Entities
    class EpisodeOrm < Sequel::Model(:episodes)
      many_to_one :show,
                  class: :'TranSound::Database::ShowOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
