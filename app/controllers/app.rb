# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

TEMP_TOKEN_CONFIG = YAML.safe_load_file('config/temp_token.yml')

module TranSound
  # Application inherits from Roda
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: ['table_row.js', 'scripts.js']
    plugin :common_logger, $stderr

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    route do |routing|
      routing.assets # load custom CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      temp_token = TranSound::Podcast::Api::Token.new(App.config, App.config.spotify_Client_ID,
                                                      App.config.spotify_Client_secret, TEMP_TOKEN_CONFIG).get

      # GET /
      routing.root do
        # Get cookie viewer's previously seen projects
        session[:watching] ||= []

        # Load previously viewed episodes
        episodes = Repository::For.klass(Entity::Episode)
          .find_podcast_infos(session[:watching])
        # shows = Repository::For.klass(Entity::Show)
        #   .find_podcast_infos(session[:watching])

        session[:watching] = episodes.map(&:origin_id)
        # session[:watching] = shows.map(&:origin_id)
        puts "Session: #{session[:watching]}"
        puts "Episodes: #{episodes}"
        puts "Session: #{session[:watching]}"
        # puts "Shows: #{shows}"

        if episodes.none?
          flash.now[:notice] = 'Add a Spotify Podcast Episode to get started'
          puts 'episodes = none'
        end
        # if shows.none?
        #   flash.now[:notice] = 'Add a Spotify Podcast Show to get started'
        #   puts 'shows = none'
        # end

        viewable_episodes = Views::EpisodesList.new(episodes)
        # viewable_shows = Views::ShowsList.new(shows)

        view 'home', locals: { episodes: viewable_episodes } # , shows: viewable_shows }
        # view 'home'
      end

      # podcast_info
      routing.on 'podcast_info' do
        puts TEMP_TOKEN_CONFIG

        routing.is do
          # POST /episode/
          routing.post do
            spot_url = routing.params['spotify_url']
            unless (spot_url.include? 'open.spotify.com') &&
                   (spot_url.split('/').count >= 3)
              flash[:error] = 'Invalid URL for a Spotify page (Require for a Spotify Episode or a Spotify Show)'
              response.status = 400
              routing.redirect '/'
            end

            type, id = spot_url.split('/')[-2..]

            # Get podcast_info from Spotify
            if type == 'episode'
              podcast_info = TranSound::Podcast::EpisodeMapper.new(temp_token).find("#{type}s", id, 'TW')
            elsif type == 'show'
              podcast_info = TranSound::Podcast::ShowMapper.new(temp_token).find("#{type}s", id, 'TW')
            else
              # handle unknown spotify_url
              routing.redirect '/'
            end

            # Add data to database
            begin
              Repository::For.entity(podcast_info).create(podcast_info)
            rescue StandardError
              flash[:error] = "Podcast #{type} information already exists"
              routing.redirect '/'
            end

            # Add new project to watched set in cookies
            session[:watching].insert(0, podcast_info.origin_id).uniq!

            # Redirect viewer to episode page or show page
            routing.redirect "podcast_info/#{type}/#{id}"
          end
        end

        routing.on String, String do |type, id|
          # DELETE /podcast_info/{type}/{id}
          routing.delete do
            fullname = id.to_s
            session[:watching].delete(fullname)

            routing.redirect '/'
          end

          languages_dict = Views::LanguagesList.new.lang_dict

          # GET /episode/id or /show/id
          if type == 'episode'
            # Get project from database
            spotify_episode = Repository::For.klass(Entity::Episode).find_podcast_info(id)
            puts "spotify_episode: #{spotify_episode}"
            view 'episode', locals: { episode: spotify_episode, lang_dict: languages_dict }

          elsif type == 'show'
            # Get data from API
            # spotify_show = TranSound::Podcast::ShowMapper.new(TEMP_TOKEN).find("#{type}s", id, 'TW')

            # Get data from database
            spotify_show = Repository::For.klass(Entity::Show).find_podcast_info(id)
            view 'show', locals: { show: spotify_show }

          else
            # Handle unknown URLs (unknown type)
            routing.redirect '/'
          end
        end
      end
    end
  end
end
