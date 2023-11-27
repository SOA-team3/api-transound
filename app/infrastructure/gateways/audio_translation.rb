# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module TranslatingUtils
      # Object for translation by Google Translate Library
      class GoogleTranslate
        def initialize(text, translate_language)
          @text = text
          @translate_language = translate_language
          # Execute Python translating script
          @script_file = 'python_utils/translator/google_translator.py'
        end

        def translate
          # Open Python Script and write in "text" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            # stdin.puts("#{@text} #{@translate_language}")
            stdin.puts(@text)
            stdin.puts(@translate_language)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return translation as String from Python script
          end
          # Must return again for the value of translate method
        end
      end
    end
  end
end

# Google Translate version(free)
# text = 'These Tiny Pollinators Can Travel Surprisingly Huge Distances.'
# translate_language = 'zh-tw'
# podcast_translation = TranSound::Podcast::TranslatingUtils::GoogleTranslate.new(text, translate_language).translate
# puts "podcast_translation:\n#{podcast_translation}"
