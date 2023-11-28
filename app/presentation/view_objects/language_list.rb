# frozen_string_literal: true

require 'yaml'

module Views
  # View for a list of language entities
  class LanguagesList
    attr_reader :lang_dict

    def initialize
      file_path = 'app/presentation/assets/yml/languages.yml'
      @lang_dict = YAML.load_file(file_path)
    end
  end
end

# puts Views::LanguagesList.new.lang_dict
