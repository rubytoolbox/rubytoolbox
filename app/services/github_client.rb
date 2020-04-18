# frozen_string_literal: true

class GithubClient
  class InvalidResponse < StandardError; end
  class InvalidResponseStatus < StandardError; end
  class UnknownRepoError < StandardError; end

  DEFAULT_TIMEOUT = 5.seconds
  REPOSITORY_DATA_QUERY = Rails.root.join("app", "graphql-queries", "github", "repo.graphql").read

  attr_accessor :token, :http_client
  private :token=, :http_client=

  # Acquire token via https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql
  # and https://github.com/settings/tokens
  #
  # No OAuth scopes are needed at all.
  def initialize(token: ENV["GITHUB_TOKEN"])
    self.token = token
    self.http_client = HTTP
                       .timeout(connect: DEFAULT_TIMEOUT, write: DEFAULT_TIMEOUT, read: DEFAULT_TIMEOUT)
  end

  def fetch_repository(path)
    owner, name = path.split("/")
    body = { query: REPOSITORY_DATA_QUERY, variables: { owner: owner, name: name } }
    response = authenticated_client.post "https://api.github.com/graphql", body: Oj.dump(body, mode: :compat)
    handle_response response
  end

  private

  def handle_response(response)
    raise InvalidResponseStatus, "status=#{response.status}" unless response.status == 200

    parsed_body = Oj.load(response.body)
    handle_errors! parsed_body["errors"]

    RepositoryData.new parsed_body
  end

  def handle_errors!(errors)
    return unless errors

    raise UnknownRepoError, errors.inspect if errors.any? { |e| e["type"] == "NOT_FOUND" }

    raise InvalidResponse, errors.map { |e| e["message"] }.join(", ")
  end

  def authenticated_client
    @authenticated_client ||= http_client.headers(
      authorization: "bearer #{token}",
      "User-Agent" => HttpService::USER_AGENT
    )
  end
end
