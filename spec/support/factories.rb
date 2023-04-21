# frozen_string_literal: true

module Factories
  # rubocop:disable Metrics/MethodLength All-in-one-place is more relevant than short methods here
  # rubocop:disable Metrics/ParameterLists Yeah we kinda need it here to customize the thing :/
  class << self
    def project(name,
                score: 25,
                downloads: 5000,
                first_release: Date.new(2020, 3, 12),
                latest_release: Date.new(2021, 1, 2),
                description: nil)

      rubygem = self.rubygem(name, downloads:, first_release:, latest_release:)

      github_repo = GithubRepo.create!(
        path:             "#{name}/#{name}",
        stargazers_count: downloads,
        forks_count:      downloads,
        watchers_count:   downloads,
        has_issues:       true
      )
      Project.create! permalink:   name,
                      score:,
                      rubygem:,
                      github_repo:,
                      description:
    end
    # rubocop:enable Metrics/ParameterLists

    def rubygem(name, downloads: 5000, first_release: Date.new(2018, 2, 28), latest_release: Date.new(2021, 1, 2))
      Rubygem.create!(
        name:,
        current_version:   "1.0",
        downloads:,
        first_release_on:  first_release,
        latest_release_on: latest_release
      )
    end

    def rubygem_download_stat(name, date:, total_downloads: 5000)
      Rubygem::DownloadStat.create! rubygem_name:    name,
                                    date:,
                                    total_downloads:
    end

    def rubygem_trend(name, date:, position:, with_stats: false)
      date = Date.parse(date.to_s)
      if with_stats
        rubygem_download_stat name, date: date - 8.weeks, total_downloads: 500
        rubygem_download_stat name, date: date - 4.weeks, total_downloads: 2000
      end
      Rubygem::Trend.create! rubygem_name:          name,
                             position:,
                             date:,
                             rubygem_download_stat: rubygem_download_stat(name, date:, total_downloads: 15_000)
    end

    def category(name)
      Category.create! permalink:      name.underscore,
                       name:,
                       category_group: CategoryGroup.create!(name: "Group", permalink: "group")
    end
  end
  # rubocop:enable Metrics/MethodLength
end
