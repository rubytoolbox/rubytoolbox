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

  delegate :description,
           :downloads,
           :first_release_on,
           :latest_release_on,
           :releases_count,
           to: :rubygem,
           allow_nil: true,
           prefix: :rubygem

  delegate :stargazers_count,
           :forks_count,
           :watchers_count,
           :description,
           to: :github_repo,
           allow_nil: true,
           prefix: :github_repo

  def self.find_for_show!(permalink)
    includes(:github_repo, :rubygem, :categories).find(permalink)
  end

  def github_only?
    permalink.include? "/"
  end

  def description
    rubygem_description || github_repo_description
  end

  def github_repo_path=(github_repo_path)
    super github_repo_path&.downcase&.strip
  end
end
