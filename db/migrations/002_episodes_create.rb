# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:episodes) do
      primary_key :id
      foreign_key :show_id, :shows

      String :description
      String :origin_id, unique: true
      String :images
      String :language
      String :name
      String :release_date
      String :type
      String :episode_url
      String :episode_mp3_url
      Integer :podcast_length
      String :transcript
      String :sentence_segments
      String :translation
      Float :difficulty_score
      String :word_dict
      String :difficult_words
      String :moderate_words
      String :easy_words

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
