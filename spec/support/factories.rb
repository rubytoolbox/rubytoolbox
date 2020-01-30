# frozen_string_literal: true

module Factories
  # rubocop:disable Metrics/MethodLength All-in-one-place is more relevant than short methods here
  class << self
    def project(name,
                score: 25,
                downloads: 5000,
                first_release: 1.year.ago,
                description: nil)

      rubygem = self.rubygem name, downloads: downloads, first_release: first_release

      github_repo = GithubRepo.create!(
        path:             "#{name}/#{name}",
        stargazers_count: downloads,
        forks_count:      downloads,
        watchers_count:   downloads,
        has_issues:       true
      )
      Project.create! permalink:   name,
                      score:       score,
                      rubygem:     rubygem,
                      github_repo: github_repo,
                      description: description
    end

    def rubygem(name, downloads: 5000, first_release: 1.year.ago, latest_release: 3.months.ago)
      Rubygem.create!(
        name:              name,
        current_version:   "1.0",
        downloads:         downloads,
        first_release_on:  first_release,
        latest_release_on: latest_release
      )
    end

    def rubygem_download_stat(name, date:, total_downloads: 5000)
      Rubygem::DownloadStat.create! rubygem_name:    name,
                                    date:            date,
                                    total_downloads: total_downloads
    end

    def rubygem_trend(name, date:, position:, with_stats: false)
      date = Date.parse(date.to_s)
      if with_stats
        rubygem_download_stat name, date: date - 8.weeks, total_downloads: 500
        rubygem_download_stat name, date: date - 4.weeks, total_downloads: 2000
      end
      Rubygem::Trend.create! rubygem_name:          name,
                             position:              position,
                             date:                  date,
                             rubygem_download_stat: rubygem_download_stat(name, date: date, total_downloads: 15_000)
    end
  end
  # rubocop:enable Metrics/MethodLength
end
