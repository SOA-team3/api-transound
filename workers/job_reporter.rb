# frozen_string_literal: true

require_relative 'progress_publisher'

module EpisodeInfo
  # Worker to report job status
  class JobReporter
    attr_reader :token, :id

    def initialize(request_json, config)
      req = JSON.parse(request_json) # message[0]=temp_token, message[1]=id
      @token = req[0]
      @id = req[1]
      @publisher = ProgressPublisher.new(config, req[2])
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
