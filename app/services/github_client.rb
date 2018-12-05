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
    owner, name = real_path(path).split("/")
    body = { query: REPOSITORY_DATA_QUERY, variables: { owner: owner, name: name } }
    response = authenticated_client.post "https://api.github.com/graphql", body: Oj.dump(body, mode: :compat)
    handle_response response
  end

  private

  # Unfortunate hack for a limitation in github's graphql API.
  # See https://github.com/rubytoolbox/rubytoolbox/pull/94#issuecomment-372489342
  # and https://platform.github.community/t/repository-redirects-in-api-v4-graphql/4417
  def real_path(path)
    response = http_client.head File.join("https://github.com", path)
    case response.status
    when 200
      return path
    # Instead of following 301s, the broken github path
    # (either coming from the catalog for github-only projects,
    # or from a rubygems urls) should somehow be flagged and
    # remapped locally, but this needs some more consideration
    # regarding the various possible cases
    when 301, 302
      location = Github.detect_repo_name response.headers["Location"]
      return location if location
    end

    raise UnknownRepoError, "Cannot find repo #{path} on github :("
  end

  def handle_response(response)
    raise InvalidResponseStatus, "status=#{response.status}" unless response.status == 200

    parsed_body = Oj.load(response.body)
    raise InvalidResponse, parsed_body["errors"].map { |e| e["message"] }.join(", ") if parsed_body["errors"]

    RepositoryData.new parsed_body
  end

  def authenticated_client
    @authenticated_client ||= http_client.headers(
      authorization: "bearer #{token}",
      "User-Agent" => HttpService::USER_AGENT
    )
  end
end
