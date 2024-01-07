# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'
require 'yaml'
require_app

SECRET = App.config

module TranSound
  module Podcast
    module TranscribingUtils
      # Object for transcription by OpenAI api
      class OpenAIWhisper
        def initialize(audio_file_path, audio_file_name)
          @audio_file_path = "#{audio_file_path}#{audio_file_name}"
          @openai_api_key = SECRET['test']['OPENAI_API_KEY']
          # Execute Python OpenAIWhisper transcribing script
          @script_file = 'python_utils/transcriber/transcribe_openai.py'
        end

        def transcribe
          # Open Python Script and write in "audio_file_name" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@audio_file_path)
            stdin.puts(@openai_api_key)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return transcrption as String from Python script
          end
          # Must return again for the value of transcribe method
        end
      end

      # Object for transcription by Speech_Recognition model
      class SpeechRecognition
        def initialize(audio_file_path, audio_file_name)
          @audio_file_path = "#{audio_file_path}#{audio_file_name}"
          # Execute Python SpeechRecognition transcribing script
          @script_file = 'python_utils/transcriber/transcribe_speech_recognition.py'
        end

        def transcribe
          # Open Python Script and write in "audio_file_name" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@audio_file_path)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return transcrption as String from Python script
          end
          # Must return again for the value of transcribe method
        end
      end

      # Object for transcription by Whisper model and FFMPEG package
      class Whisper
        def initialize(audio_file_path)
          @audio_file_path = audio_file_path
          # Execute Python Scraping script
          @script_file = 'python_utils/transcriber/transcribe_whisper.py'
        end

        def transcribe
          # Open Python Script and write in "audio_file_path" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@audio_file_path)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return transcrption as String from Python script
            # output = stdout.read
            # output
          end
          # Must return again for the value of transcribe method
        end
      end
    end
  end
end

# OpenAIWhisper version(charge)
# audio_file_path = 'podcast_mp3_store/'
# audio_file_name = 'Ricky Gervais: A Joke About His Will.mp3'
# podcast_transcription = TranSound::Podcast::TranscribingUtils::OpenAIWhisper.new(audio_file_path, audio_file_name).transcribe
# puts "Podcast_transcription: \n#{podcast_transcription}"

# SpeechRecognition version(free)
# audio_file_path = 'podcast_mp3_store/'
# audio_file_name = 'Ricky Gervais: A Joke About His Will.mp3'
# podcast_transcription =
#   TranSound::Podcast::TranscribingUtils::SpeechRecognition.new(audio_file_path, audio_file_name).transcribe
# puts "podcast_transcription: #{podcast_transcription}"
