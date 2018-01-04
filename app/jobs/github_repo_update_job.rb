# frozen_string_literal: true

class GithubRepoUpdateJob < ApplicationJob
  def perform(path)
    info = fetch_repo_info path

    if info
      GithubRepo.find_or_initialize_by(path: path.downcase).tap do |repo|
        # Set updated at to ensure we flag what we've pulled
        repo.updated_at = Time.current.utc
        repo.update_attributes! mapped_attributes(info)
      end
      ProjectUpdateJob.perform_async path
    else
      GithubRepo.where(path: path).destroy_all
    end
  end

  private

  ATTRIBUTE_MAPPING = {
    stargazers_count: :stargazers_count,
    subscribers_count: :watchers_count,
    forks_count: :forks_count,
  }.freeze

  def mapped_attributes(info)
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      mapped[local_name] = info[remote_name.to_s].presence
    end
  end

  def fetch_repo_info(path)
    url = File.join("https://api.github.com", "repos", path)
    response = github_client.get url, params: github_credentials

    return nil if response.status == 404
    return Oj.load(response.body)  if response.status == 200

    raise "Unknown response status #{response.status.to_i}"
  end

  def github_client
    HttpService.client.headers(
      accept: "application/vnd.github.v3+json"
    )
  end

  def github_credentials
    {
      client_id: ENV["GITHUB_CLIENT_ID"],
      client_secret: ENV["GITHUB_CLIENT_SECRET"],
    }
  end
end
