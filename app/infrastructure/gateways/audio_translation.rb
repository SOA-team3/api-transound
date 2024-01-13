# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module TranslatingUtils
      # Object for translation by Google Translate Library
      class Translator
        def initialize(text, translate_language)
          @text = text
          @translate_language = translate_language
          # Execute Python translating script
          @script_file = 'python_utils/translator/translator.py'
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

# Translate version(free)
# text = "MUSIC I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically. There's a new baby every Christmas. It's one of those families. I go home, it's crowded. I go, oh, oh, who's this? Oh, yours? Oh, well done. I don't know him, I don't know her. You know what I mean? It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right? But to keep it secret. So they all love me, right? And I'm not doing a will, so my funeral is going to be a fucking bloodbath. LAUGHTER"
# text = "There's a new baby every Christmas."
# translate_language = 'zh-tw'
# podcast_translation = TranSound::Podcast::TranslatingUtils::Translator.new(text, translate_language).translate
# puts "Podcast_translation:\n#{podcast_translation}"
