# frozen_string_literal: true

module Factories
  # rubocop:disable Metrics/MethodLength All-in-one-place is more relevant than short methods here
  class << self
    def project(name,
                score:,
                downloads: 5000,
                first_release: 1.year.ago,
                description: nil)
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
      Project.create! permalink:   name,
                      score:       score,
                      rubygem:     rubygem,
                      github_repo: github_repo,
                      description: description
    end
  end
  # rubocop:enable Metrics/MethodLength
end
