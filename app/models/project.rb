# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Project < ApplicationRecord
  self.primary_key = :permalink

  has_many :categorizations,
           primary_key: :permalink,
           foreign_key: :project_permalink,
           inverse_of:  :project,
           validate:    false,
           dependent:   :destroy

  has_many :categories, through: :categorizations

  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             optional:    true,
             inverse_of:  :project

  belongs_to :github_repo,
             primary_key: :path,
             foreign_key: :github_repo_path,
             optional:    true,
             inverse_of:  :projects

  scope :includes_associations, lambda {
    includes(:github_repo, :rubygem, :categories)
      .left_outer_joins(:github_repo, :rubygem, :categories)
  }

  scope :with_score, -> { where.not(score: nil) }

  def self.with_bugfix_forks(include_forks)
    include_forks ? self : where(is_bugfix_fork: false)
  end

  def self.for_display(forks: false)
    includes_associations
      .with_bugfix_forks(forks)
      .with_score
  end

  include PgSearch
  pg_search_scope :search_scope,
                  # This is unfortunately not used when using explicit tsvector columns,
                  # see https://github.com/Casecommons/pg_search#using-tsvector-columns
                  against:   { permalink_tsvector: "A", description_tsvector: "C" },
                  using:     {
                    tsearch: {
                      tsvector_column: %w[permalink_tsvector description_tsvector],
                      prefix:          true,
                      dictionary:      "simple",
                    },
                  },
                  ranked_by: ":tsearch * (#{table_name}.score + 1) * (#{table_name}.score + 1)"

  def self.search(query, order: Project::Order.new(directions: Project::Order::SEARCH_DIRECTIONS), show_forks: false)
    with_score
      .with_bugfix_forks(show_forks)
      .search_scope(query)
      .reorder("")
      .includes_associations
      .order(order.sql)
  end

  delegate :current_version,
           :description,
           :documentation_url,
           :downloads,
           :first_release_on,
           :homepage_url,
           :source_code_url,
           :latest_release_on,
           :releases_count,
           :mailing_list_url,
           :changelog_url,
           :wiki_url,
           :bug_tracker_url,
           :licenses,
           :url,
           :reverse_dependencies_count,
           to:        :rubygem,
           allow_nil: true,
           prefix:    :rubygem

  delegate :stargazers_count,
           :forks_count,
           :homepage_url,
           :watchers_count,
           :description,
           :archived?,
           :repo_pushed_at,
           :wiki_url,
           :issues_url,
           :url,
           :primary_language,
           :has_issues,
           :license,
           :default_branch,
           :is_fork,
           :is_mirror,
           :open_issues_count,
           :closed_issues_count,
           :issue_closure_rate,
           :total_issues_count,
           :open_pull_requests_count,
           :merged_pull_requests_count,
           :closed_pull_requests_count,
           :pull_request_acceptance_rate,
           :average_recent_committed_at,
           :sibling_gem_with_most_downloads,
           to:        :github_repo,
           allow_nil: true,
           prefix:    :github_repo

  def self.find_for_show!(permalink)
    includes_associations.find(Github.normalize_path(permalink))
  end

  def permalink=(permalink)
    super Github.normalize_path(permalink)
  end

  def github_only?
    permalink.include? "/"
  end

  def github_repo_path=(github_repo_path)
    super Github.normalize_path(github_repo_path)
  end

  alias documentation_url rubygem_documentation_url
  alias changelog_url rubygem_changelog_url
  alias mailing_list_url rubygem_mailing_list_url

  def source_code_url
    rubygem_source_code_url || github_repo_url
  end

  def homepage_url
    rubygem_homepage_url || github_repo_homepage_url
  end

  def wiki_url
    rubygem_wiki_url || github_repo_wiki_url
  end

  def bug_tracker_url
    rubygem_bug_tracker_url || github_repo_issues_url
  end
end
# rubocop:enable Metrics/ClassLength
