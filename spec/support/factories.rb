# frozen_string_literal: true

module Factories
  class << self
    def project(name, score:, downloads:, first_release:) # rubocop:disable Metrics/MethodLength
      rubygem = Rubygem.create!(
        name:             name,
        current_version:  "1.0",
        downloads:        downloads,
        first_release_on: first_release
      )
      github_repo = GithubRepo.create!(
        path:             "#{name}/#{name}",
        stargazers_count: downloads,
        forks_count:      downloads,
        watchers_count:   downloads
      )
      Project.create! permalink: name, score: score, rubygem: rubygem, github_repo: github_repo
    end
  end
end
