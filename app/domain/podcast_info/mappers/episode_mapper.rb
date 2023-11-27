# frozen_string_literal: true

require 'net/http'

module TranSound
  module Podcast
    # Utiliy of handle Audio data
    module AudioDataUtils
      # Download Audio Data
      class AudioDownloader
        def download_audio(data)
          mp3_url = data['audio_preview_url']
          local_file_path = "app/models/mappers/audio_data_download/#{data['name']}.mp3"

          # mp3_url = data
          # local_file_path = "app/models/mappers/audio_data_download/test.mp3"

          response = send_http_get_request(mp3_url)

          if response.is_a?(Net::HTTPSuccess)
            write_to_file(local_file_path, response.body)
          else
            DownloadFailureHandler.new(response).handle
          end
        end

        private

        def send_http_get_request(url)
          uri = URI(url)
          Net::HTTP.get_response(uri)
        end

        def write_to_file(file_path, content)
          File.binwrite(file_path, content)
          puts "下載完成：#{file_path}"
        end
      end

      # Handle downloading failure
      class DownloadFailureHandler
        def initialize(response)
          @response = response
        end

        def handle
          puts "下載失敗：#{@response.code} - #{@response.message}"
        end
      end
    end

    # Data Mapper: Podcast episode -> Episode entity
    class EpisodeMapper
      include AudioDataUtils

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
        end

        def build_entity
          TranSound::Entity::Episode.new(id: nil, origin_id:, description:,
                                         images:, language:,
                                         name:,
                                         release_date:,
                                         type:,
                                         episode_url:,
                                         episode_mp3_url:,
                                         transcript:,
                                         translation:)
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
          puts name
          TranSound::Podcast::WebScrapingUtils::GoogleWebScraping.new(name).scrap
        end

        def transcript
          audio_file_path = 'podcast_mp3_store/'
          audio_file_name = "#{name}.mp3"
          TranSound::Podcast::TranscribingUtils::SpeechRecognition.new(audio_file_path, audio_file_name).transcribe
        end

        def translation
          translate_language = 'zh-tw'
          text = transcript
          TranSound::Podcast::TranslatingUtils::GoogleTranslate.new(text, translate_language).translate
        end
      end
    end
  end
end
