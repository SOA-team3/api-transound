# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:episodes_shows) do
      primary_key %i[episode_id show_id]
      foreign_key :episode_id # , :episodes
      foreign_key :show_id, :shows

      index %i[episode_id show_id]
    end
  end
end
