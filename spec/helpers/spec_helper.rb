# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

# get TranSound::Token class
require_relative '../../app/infrastructure/gateways/podcast_api'

require_relative '../../require_app'
require_app

# should contain CONST that pass into spec(podcast_info)
EPISODE_TYPE = 'episode' # 'episodes'
SHOW_TYPE = 'show' # 'shows'
EPISODE_ID = '2zplNaMpre0ASbFJV7OSSq' # '7vwvbU1pDkv0IuWPY8SZyz'
SHOW_ID = '5Vv32KtHB3peVZ8TeacUty'
MARKET = 'TW'

SECRET_PATH = 'config/secrets.yml'
CONFIG = YAML.safe_load_file(SECRET_PATH)
TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')
CLIENT_ID = CONFIG['test']['spotify_Client_ID']
CLIENT_SECRET = CONFIG['test']['spotify_Client_secret']
TEMP_TOKEN = TranSound::Podcast::Api::Token.new(CONFIG, CLIENT_ID,
                                                CLIENT_SECRET, TEMP_TOKEN_CONFIG).get
EPISODE_CORRECT = YAML.safe_load_file('spec/fixtures/episode_results.yml')
SHOW_CORRECT = YAML.safe_load_file('spec/fixtures/show_results.yml')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'podcast_api[.yml]'
