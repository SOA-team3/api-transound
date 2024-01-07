# frozen_string_literal: true

module TranSound
  module Repository
    # Repository for Episode Entities
    class Episodes
      def self.find_podcast_info(origin_id)
        # SELECT * FROM episodes LEFT JOIN shows
        # ON (`shows`.`origin_id` = `episodes`.`show_id`)
        # WHERE (`origin_id` = 'origin_id')
        # .left_join(:members, id: :owner_id)
        db_project = Database::EpisodeOrm
          .where(origin_id:)
          .first
        rebuild_entity(db_project)
      end

      def self.find_podcast_infos(origin_ids)
        origin_ids.map do |origin_id|
          find_podcast_info(origin_id)
        end.compact
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::EpisodeOrm.first(id:)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::EpisodeOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Episode already exists' if find(entity)

        # return if find(entity)

        db_record = Database::EpisodeOrm.create(entity.to_attr_hash)
        puts "Create db_record: #{db_record}"
        puts "EpisodeOrm: #{Database::EpisodeOrm.all}"
        rebuild_entity(db_record)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Episode.new(id: db_record.id, origin_id: db_record.origin_id, name: db_record.name,
                            description: db_record.description, images: db_record.images, language: db_record.language,
                            release_date: db_record.release_date,
                            type: db_record.type,
                            episode_url: db_record.episode_url,
                            episode_mp3_url: db_record.episode_mp3_url,
                            podcast_length: db_record.podcast_length,
                            transcript: db_record.transcript,
                            sentence_segments: db_record.sentence_segments,
                            translation: db_record.translation,
                            difficulty_score: db_record.difficulty_score,
                            word_dict: db_record.word_dict,
                            difficult_words: db_record.difficult_words,
                            moderate_words: db_record.moderate_words,
                            easy_words: db_record.easy_words)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_episode|
          Episodes.rebuild_entity(db_episode)
        end
      end
    end
  end
end
