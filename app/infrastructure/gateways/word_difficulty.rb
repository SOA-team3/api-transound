# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'
require 'yaml'

module TranSound
  module Podcast
    module WordDifficultyUtils
      # Object for calculating Word Difficulty by nltk Library
      class NLTKWordDifficulty
        def initialize(word)
          @word = word
          puts "initialize word: #{word}"
          # Execute Python translating script
          @script_file = 'python_utils/word_difficulty_calulator/nltk_word_difficulty.py'
        end

        def calculate_word_difficulty
          # Open Python Script and write in "word" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@word)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return word-difficulty as String from Python script
          end
          # Must return again for the value of translate method
        end
      end

      # Object for calculating Word-Difficulty by nltk Library and write in Word-Difficulty-Dict in Yaml file
      class NLTKWordDifficultyDict
        def initialize(transcript)
          @transcript = transcript
          # Execute Python translating script
          @script_file = 'python_utils/word_difficulty_calulator/nltk_word_difficulty_dict.py'
        end

        def create_word_difficulty_dict
          # Open Python Script and write in "word" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@transcript)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return word_difficulty_dict as hash-like String from Python script
          end
        end
      end
    end
  end
end

# nltk version(free) - calculate the difficulty of one single word
# word = 'free'
# word_difficulty = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficulty.new(word).calculate_word_difficulty
# puts "Word_difficulty:\n#{word_difficulty}"

# nltk version(free) - calculate the difficulty of one single word
# TEST_TRANSCRIPT = YAML.safe_load_file('app/domain/podcast_difiiculty/lib/test_transcript.yml')
# TEST_TRANSCRIPT = "this is Scientific American 60-second Science I'm Christopher and Toyota when you think of pollinators what comes to mind bees butterflies maybe hummingbirds well how about flies in general are the second most important group of pollinating insects so I think that they deserve more credit than than they often get see Scott Clem is an insect ecologist at the University of Georgia and he's been studying a type of fly known as a hoverfly you may have actually seen them before masquerading as bees and wasps they tend to be yellow and black colored and they're kind of different from other flies in that regard they're these little text that you're often find visiting flowers or sometimes they'll actually land on your skin so you can the salt on your skin by setting Isotopes in the insects legs and wings clementis colleagues have now determined that some of these flies make remarkable Autumn migration they seem to originate near Ontario Canada and then they fly hundreds of miles south to Central Illinois and it's possible that some go even further thousands of miles perhaps they get up and high altitude air currents able to just surf on these winds basically and it takes them these these vast distances the results appear in the journal ecological monographs as for why the Flies migrate well Clem says they might be pursuing the aphids they eat or maybe they're following the blooms of nectar-rich flowers and if they're moving they could be moving these ecological Services across the continent on an annual basis the scientists write that the Flies could be transporting billions of grains of pollen what's the continent all while working to exterminate pests so even if hoverflies be like appearance is mirror mimicry the ecological Services they provide could very well be the real deal thanks for listening for Scientific American"
# word_difficulty_dict = TranSound::Podcast::WordDifficultyUtils::NLTKWordDifficultyDict.new(TEST_TRANSCRIPT).create_word_difficulty_dict
# puts "Word_difficulty:\n#{word_difficulty_dict}"
# puts word_difficulty_dict.class
