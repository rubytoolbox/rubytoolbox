# frozen_string_literal: true

module HttpService
  USER_AGENT = "ruby-toolbox.com API client"

  class << self
    def client
      if Rails.configuration.http_connect
        real_http_client
      else
        mock_http_client
      end
    end

    private

    def real_http_client
      HTTP.timeout(connect: 3, write: 3, read: 3)
          .headers(
            "Accept" => "application/json",
            "Content-Type" => "application/json",
            "User-Agent" => USER_AGENT
          )
    end

    def mock_http_client
      MockClient.new
    end
  end

  class MockClient
    class UnmockedRequestError < StandardError; end

    def get(url, **_args)
      response = responses[url]
      raise UnmockedRequestError unless response
      HTTP::Response.new(status: response["status"], body: response["body"], version: "1.1")
    end

    def headers(*_args)
      self
    end

    def follow
      self
    end

    def responses
      YAML.load_file responses_source_file_path
    end

    def responses_source_file_path
      Rails.root.join("config", "http_mock_responses.yml")
    end
  end
end
