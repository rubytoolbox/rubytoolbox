# frozen_string_literal: true

class GithubClient
  class InvalidResponse < StandardError; end

  REPOSITORY_QUERY_TEMPLATE = Tilt.new(Rails.root.join("app", "graphql-queries", "github", "repo.erb"))

  attr_accessor :token, :http_client
  private :token=, :http_client=

  # Acquire token via https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql
  # and https://github.com/settings/tokens
  #
  # No OAuth scopes are needed at all.
  def initialize(token: ENV["GITHUB_TOKEN"])
    self.token = token
    self.http_client = HTTP
                       .headers(authorization: "bearer #{token}", "User-Agent" => HttpService::USER_AGENT)
                       .timeout(connect: 3, write: 3, read: 3)
  end

  def fetch_repository(path)
    owner, name = path.split("/")
    query = REPOSITORY_QUERY_TEMPLATE.render(OpenStruct.new(owner: owner, name: name))
    response = http_client.post("https://api.github.com/graphql", body: { query: query }.to_json)
    handle_response response
  end

  private

  def handle_response(response)
    parsed_body = Oj.load(response.body)
    raise InvalidResponse, parsed_body["errors"].map { |e| e["message"] }.join(", ") if parsed_body["errors"]
    RepositoryData.new parsed_body
  end
end
