# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    TranSound::App.db.run('PRAGMA foreign_keys = OFF')
    TranSound::Database::ShowOrm.map(&:destroy)
    TranSound::Database::EpisodeOrm.map(&:destroy)
    TranSound::App.db.run('PRAGMA foreign_keys = ON')
  end
end
