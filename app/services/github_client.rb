# frozen_string_literal: true

class GithubClient
  class InvalidResponse < StandardError; end
  class InvalidResponseStatus < StandardError; end
  class UnknownRepoError < StandardError; end

  # Object for holding readme API data responses
  ReadmeData = Struct.new(:html, :etag)

  DEFAULT_TIMEOUT = 15.seconds
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
    handle_repo_response response
  end

  def fetch_readme(path, etag: nil)
    response = authenticated_client.headers(
      # We want pre-parsed html here to be as close to canonical rendering as possible
      accept: "application/vnd.github.v3.html",
      # Cache hits don't count against rate limits
      "If-None-Match" => etag
    ).follow.get("https://api.github.com/repos/#{path}/readme")

    # Ignore cache hits and missing readmes
    return if [304, 404].include? response.status

    ensure_success! response.status

    ReadmeData.new response.body.to_s, response.headers["Etag"]
  end

  private

  def ensure_success!(status)
    return true if status == 200

    raise InvalidResponseStatus, "status=#{status}"
  end

  def handle_repo_response(response)
    ensure_success! response.status

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
