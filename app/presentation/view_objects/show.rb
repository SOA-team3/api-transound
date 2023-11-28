# frozen_string_literal: true

module Views
  # View for a single Show entity
  class Show
    def initialize(show, index = nil)
      @show = show
      @index = index
    end

    def entity
      @show
    end

    def link
      "/podcast_info/show/#{@show.origin_id}"
    end

    def index_str
      "show[#{@index}]"
    end

    def name
      @show.name
    end

    def origin_id
      @show.origin_id
    end

    def show_url
      @show.show_url
    end

    def publisher
      @show.publisher
    end
  end
end
