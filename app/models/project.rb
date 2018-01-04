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
           to: :rubygem,
           allow_nil: true,
           prefix: :rubygem

  def github_only?
    permalink.include? "/"
  end

  def description
    rubygem_description
  end

  def score
    rand(100).round(2)
  end
end
