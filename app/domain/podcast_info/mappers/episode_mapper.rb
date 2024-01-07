# frozen_string_literal: true

require 'json'
require 'net/http'
require_app

module TranSound
  module Podcast
    # Data Mapper: Podcast episode -> Episode entity
    class EpisodeMapper
      def initialize(token, gateway_class = Podcast::Api)
        @spot_token = token
        @gateway_class = gateway_class
        @gateway = gateway_class.new(@spot_token)
      end

      def find(type, id, market)
        data = @gateway.episode_data(type, id, market)
        # AudioDownloader.new.download_audio(data)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @spot_token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        include WebScrapingUtils

        def initialize(data, token, gateway_class)
          @episode = data
          @spot_token = token
          @gateway_class = gateway_class
          @config = App.config
        end

        def build_entity
          TranSound::Entity::Episode.new(id: nil, origin_id:, description:,
                                         images:, language:, name:,
                                         release_date:, type:, episode_url:,
                                         episode_mp3_url:, podcast_length:, transcript:,
                                         sentence_segments:, translation:,
                                         difficulty_score:, word_dict:,
                                         difficult_words:, moderate_words:, easy_words:)
        end

        def origin_id
          @episode['id']
        end

        def description
          @episode['description']
        end

        def images
          # @episode['images'] ## if images-type == Array
          @episode['images'][0]['url']
        end

        def language
          @episode['language']
        end

        def name
          @episode['name']
        end

        def release_date
          @episode['release_date']
        end

        def type
          @episode['type']
        end

        def episode_url
          "https://open.spotify.com/#{type}/#{origin_id}"
        end

        def episode_mp3_url
          puts "Name of episode_mp3_url: #{name}"
          TranSound::Podcast::WebScrapingUtils::GoogleWebScraping.new(name).scrap
        end

        def podcast_length
          @episode['duration_ms']
        end

        def transcript
          audio_file_path = 'podcast_mp3_store/'
          audio_file_name = "#{name}.mp3"

          # TranSound::Podcast::TranscribingUtils::SpeechRecognition.new(audio_file_path, audio_file_name).transcribe
          transcript = TranSound::Podcast::TranscribingUtils::OpenAIWhisper.new(audio_file_path, audio_file_name).transcribe
          # transcript = <<-EOF
          #   I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically.
          #   There's a new baby every Christmas.
          #   It's one of those families.
          #   I go home, it's crowded.
          #   I go, oh, oh, who's this?
          #   Oh, yours?
          #   Oh, well done.
          #   I don't know him, I don't know her.
          #   You know what I mean?
          #   It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right?
          #   But to keep it secret.
          #   So they all love me, right?
          #   And I'm not doing a will, so my funeral is going to be a fucking bloodbath.
          # EOF

          # Remove non-text, ex:"LAUGHTER" and "MUSIC"
          transcript.gsub(/(LAUGHTER|MUSIC)\s*/, '')
        end

        def sentence_segments
          sentences = TranSound::Podcast::SegmentingUtils::TextSegmentation.new(transcript).segment
          sentences.to_json
        end

        def translation
          translate_language = 'zh-tw'
          sentences = JSON.parse(sentence_segments)
          translate_sentences = []
          sentences.each do |sentence|
            translate_sentences << TranSound::Podcast::TranslatingUtils::OpenAITranslator.new(sentence.strip, translate_language).translate
            # translate_sentences << TranSound::Podcast::TranslatingUtils::Translator.new(sentence.strip, translate_language).translate
          end
          translate_sentences.to_json
        end

        def difficulty_score
          @words_difficulty_dict = TranSound::Entity::DifficultyScores.new(transcript).words_difficulty_dict_by_transcript
          TranSound::Value::Scoring.new(@words_difficulty_dict).podcast_difficult_score
          # words_difficulty_dict = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict.new(transcript).create_word_difficulty_dict
          # words_difficulty_dict.gsub!(/'(\w+)'/) { "\"#{$1}\"" }
          # @words_difficulty_dict = JSON.parse(words_difficulty_dict)
        end

        def word_dict
          @words_difficulty_dict.to_json
        end

        def difficult_words
          difficult_dict = TranSound::Value::Scoring.new(@words_difficulty_dict).difficult_dict
          difficult_dict.to_json
        end

        def moderate_words
          moderate_dict = TranSound::Value::Scoring.new(@words_difficulty_dict).moderate_dict
          moderate_dict.to_json
        end

        def easy_words
          easy_dict = TranSound::Value::Scoring.new(@words_difficulty_dict).easy_dict
          easy_dict.to_json
        end

      end
    end
  end
end
