# frozen_string_literal: true

module TranSound
  module Repository
    # Repository for Shows
    class Shows
      def self.find_podcast_info(origin_id)
        # SELECT * FROM `shows` ##LEFT JOIN `episodes` ON (`episodes`.`origin_id` = `shows`.`episode_id`)
        # WHERE (`origin_id` = 'origin_id')
        # .left_join(:members, id: :owner_id)
        db_project = Database::ShowOrm
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
        rebuild_entity Database::ShowOrm.first(id:)
      end

      def self.find_origin_id(origin_id)
        rebuild_entity Database::ShowOrm.first(origin_id:)
      end

      def self.create(entity)
        raise 'Show already exists' if find(entity)

        # return if find(entity)

        db_record = Database::ShowOrm.create(entity.to_attr_hash)
        puts "Create db_record: #{db_record}"
        puts "ShowOrm: #{Database::ShowOrm.all}"
        rebuild_entity(db_record)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Show.new(id: db_record.id, origin_id: db_record.origin_id,
                         description: db_record.description,
                         name: db_record.name,
                         images: db_record.images,
                         publisher: db_record.publisher,
                         type: db_record.type,
                         show_url: db_record.show_url)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_show|
          Shows.rebuild_entity(db_show)
        end
      end
    end
  end
end
