# frozen_string_literal: true

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module DownloaderUtils
      # Object for translation by Google Translate Library
      class NLTKPretrainedModel
        def initialize
          # Execute Python translating script
          @script_file = 'python_utils/word_difficulty_calulator/nltk_dict_download.py'
        end

        def download
          # Open Python Script and write in "text" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
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

# TranSound::Podcast::DownloaderUtils::NLTKPretrainedModel.new.download