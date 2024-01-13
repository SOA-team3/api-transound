# TranSound

Application that allows *podcast-users* to get the podcast's advanced information such as *audio-data downloading*, *translation*, *transcription*, or *summarization*.

## Overview

TranSound will pull data from Spotify's API, as well as provide podcast information.

It will then generate *texts* from downloading its audio data automatically to show translation, transcription, summarization, etc.
We call this a *trans* processing: users should feel convenient in obtaining podcast content by saving time for listening to the whole episode.

We hope this tool will enable users to listen to foreign podcasts without the language barrier, but also allow users to get summarized information. We do not want our tools to replace the way people listen to podcasts. Instead, we intend our projects to be an extended tool or advanced function for podcast users. It is upto everyone including people who have never used podcasts before or who have a disability to listen to have a quick start for using podcasts in a more convenient way.

## Objectives

### Short-term usability goals

- Pull podcast data from Spotify API, provide podcast's information
- Automated download audio data in one episode to generate translation and transcription
- Display summarization
- Episode (a single episode of a podcast, which users listen to)
- Show (a podcast show, which users subscribe to)

### Long-term goals

- Perform static analysis of folders/files: e.g., flog, rubocop, reek for Ruby

## Setup

- Create a personal Spotify API access Client ID and Client Secret with `https://developer.spotify.com/web-api`
- Copy `config/secrets_example.yml` to `config/secrets.yml` and update Client ID and Client Secret
- Ensure correct version of Ruby install (see `.ruby-version` for `rbenv`)
- Run `bundle install`

## Spotify API Client

Project to gather useful information from Spotify Web API
(https://developer.spotify.com/documentation/web-api)


## Resources

- Episode
- Show

## Elements

- Episodes
    - id
    - description
    - images
    - language
    - name
    - release_date
    - type

- Shows
    - id
    - description
    - images
    - name
    - publisher

## Entities

Podcast API data can be accessed in multiple streaming platforms, and all platforms define the main data with the term *Episode* and *Show* in CONVENTION
- *Episode* (the single episode of a podcast, which users listen to)
- *Show* (a podcast show, which users subscribe to)
(Note: A *Show* could have multiple *Episode*s)