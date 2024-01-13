# frozen_string_literal: true

require 'sequel'

module TranSound
  module Database
    # Object-Relational Mapper for Show Entities
    class ShowOrm < Sequel::Model(:shows)
      one_to_many :episodes,
                  class: :'TranSound::Database::EpisodeOrm',
                  key: :show_id

      plugin :timestamps, update_on_create: true
    end
  end
end
