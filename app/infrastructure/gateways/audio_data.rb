# frozen_string_literal: true

require 'net/http'

# Open3 library to execute Python script
require 'open3'

module TranSound
  module Podcast
    module WebScrapingUtils
      # Handle for different web scrapping pattern

      # Object for web scraping on Apple Podcast
      class AppleWebScraping
        # Execute Python scraping script
        def initialize
          @script_file = 'python_utils/web_scraper/apple_web_scraper.py'
          @urls = Open3.capture2("python3 #{@script_file} ").split
        end

        def scrap
          mp3_url = @urls[0]
          episode_url = @urls[1]
          # Return scraped mp3_url of Python script
          # puts "MP3_URL: #{mp3_url}"
          # puts "Episode_url: #{episode_url}"
          [mp3_url, episode_url]
        end
      end

      # Object for web scraping on Google Podcast
      class GoogleWebScraping
        def initialize(episode_name)
          @google_pod_url = "https://podcasts.google.com/search/#{episode_name}"
          # Execute Python Scraping script
          @script_file = 'python_utils/web_scraper/google_pod_episode_scraper.py'
        end

        def scrap
          # Open Python Script and write in "google_pod_url" as stdin
          Open3.popen2("python3 #{@script_file}") do |stdin, stdout, _wait_thr|
            stdin.puts(@google_pod_url)
            # Save the stdin in Py script and close
            stdin.close
            stdout.read
            # puts "Python script output: #{output}"

            # Return scraped mp3_url of Python script
            # output = stdout.read
            # output
          end
          # Must return again for the value of google_web_scraping method
        end
      end
    end
  end
end

# Google podcast version
# episode_name = 'YUYUの日本語Podcast Vol.233 【仕事のこと】それは仕事？仕事ごっこ？(YUYU Japanese Podcast)'
# mp3_url = TranSound::Podcast::WebScrapingUtils::WebScraper.new.google_web_scraping(episode_name)
# puts "mp3_url: #{mp3_url}"
