# frozen_string_literal: true

class Project::Order
  DIRECTIONS = {
    "score"                                   => "projects.score DESC NULLS LAST",
    "rubygem_downloads"                       => "rubygems.downloads DESC NULLS LAST",
    "rubygem_reverse_dependencies_count"      => "rubygems.reverse_dependencies_count DESC NULLS LAST",
    "rubygem_first_release_on"                => "rubygems.first_release_on ASC NULLS LAST",
    "rubygem_latest_release_on"               => "rubygems.latest_release_on DESC NULLS LAST",
    "rubygem_releases_count"                  => "rubygems.releases_count DESC NULLS LAST",
    "github_repo_stargazers_count"            => "github_repos.stargazers_count DESC NULLS LAST",
    "github_repo_forks_count"                 => "github_repos.forks_count DESC NULLS LAST",
    "github_repo_watchers_count"              => "github_repos.watchers_count DESC NULLS LAST",
    "github_repo_average_recent_committed_at" => "github_repos.average_recent_committed_at DESC NULLS LAST",
  }.freeze

  attr_reader :ordered_by

  def initialize(order:)
    self.ordered_by = order
  end

  def ordered_by=(ordered_by)
    @ordered_by = DIRECTIONS.key?(ordered_by) ? ordered_by : "score"
  end

  # Shorthand to check if given order is the current one
  def is?(order)
    ordered_by == order
  end

  def sql
    DIRECTIONS.fetch ordered_by
  end

  def available_directions
    DIRECTIONS.keys
  end

  def available_groups
    {
      "default"     => DIRECTIONS.keys.reject { |key| key =~ /^rubygem|github/ },
      "rubygem"     => DIRECTIONS.keys.select { |key| key.start_with? "rubygem_" },
      "github_repo" => DIRECTIONS.keys.select { |key| key.start_with? "github_repo_" },
    }
  end
end
