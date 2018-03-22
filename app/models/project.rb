# frozen_string_literal: true

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

  scope :includes_associations, -> { includes(:github_repo, :rubygem, :categories) }

  include PgSearch
  pg_search_scope :search_scope,
                  # This is unfortunately not used when using explicit tsvector columns,
                  # see https://github.com/Casecommons/pg_search#using-tsvector-columns
                  against: { permalink_tsvector: "A", description_tsvector: "C" },
                  using: {
                    tsearch: {
                      tsvector_column: %w[permalink_tsvector description_tsvector],
                      prefix: true,
                      dictionary: "simple",
                    },
                  },
                  ranked_by: ":tsearch * (#{table_name}.score + 1) * (#{table_name}.score + 1)"

  def self.search(query)
    where.not(score: nil).includes_associations.search_scope(query).limit(25)
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
           :url,
           to: :rubygem,
           allow_nil: true,
           prefix: :rubygem

  delegate :stargazers_count,
           :forks_count,
           :homepage_url,
           :watchers_count,
           :description,
           :wiki_url,
           :issues_url,
           :url,
           to: :github_repo,
           allow_nil: true,
           prefix: :github_repo

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
