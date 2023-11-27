# frozen_string_literal: true

require 'http'
require 'yaml'
require_relative '../../app/infrastructure/gateways/podcast_api'

EPISODE_TYPE = 'episodes'
EPISODE_ID = '2zplNaMpre0ASbFJV7OSSq' # '7elPsgSqR0DjMvMyLKSiM8'
SHOW_TYPE = 'shows'
SHOW_ID = '5Vv32KtHB3peVZ8TeacUty'
MARKET = 'TW'
SECRET_PATH = 'config/secrets.yml'
CONFIG = YAML.safe_load_file(SECRET_PATH)
CLIENT_ID = CONFIG['test']['spotify_Client_ID']
CLIENT_SECRET = CONFIG['test']['spotify_Client_secret']
puts "CLIENT_ID: #{CLIENT_ID}"
puts "CLIENT_SECRET: #{CLIENT_SECRET}"
TEMP_TOKEN_PATH = 'config/temp_token.yml'
TEMP_TOKEN_CONFIG = YAML.safe_load_file(TEMP_TOKEN_PATH)

TEMP_TOKEN = TranSound::Podcast::Api::Token.new(CONFIG, CLIENT_ID, CLIENT_SECRET, TEMP_TOKEN_CONFIG).get
puts "TEMP_TOKEN: #{TEMP_TOKEN}"

episode = TranSound::Podcast::Api.new(TEMP_TOKEN).episode_data(EPISODE_TYPE, EPISODE_ID, MARKET)
episode_results = {}
episode_results['description'] = episode['description']
episode_results['images'] = episode['images']
episode_results['name'] = episode['name']
episode_results['release_date'] = episode['release_date']

# .slice to remain keys that we want
keep_keys = %w[description images name publisher]
show_hash = episode['show'].slice(*keep_keys)
episode_results['show'] = show_hash

episode_results['type'] = episode['type']
File.write('spec/fixtures/new_episode_results.yml', episode_results.to_yaml)

show = TranSound::Podcast::Api.new(TEMP_TOKEN).show_data(SHOW_TYPE, SHOW_ID, MARKET)
show_results = {}
show_results['description'] = show['description']
show_results['images'] = show['images']
show_results['name'] = show['name']
show_results['publisher'] = show['publisher']

File.write('spec/fixtures/new_show_results.yml', show_results.to_yaml)
# show_description = show['episodes']['items'][0]['html_description']
