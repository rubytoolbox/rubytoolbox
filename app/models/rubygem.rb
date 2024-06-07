# frozen_string_literal: true

class Rubygem < ApplicationRecord
  self.primary_key = :name

  has_one :project,
          primary_key: :name,
          foreign_key: :rubygem_name,
          inverse_of:  :rubygem,
          dependent:   :destroy

  has_many :advisories, -> { order(date: :desc) },
           class_name:  "Rubygem::Advisory",
           primary_key: :name,
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :download_stats, -> { order(date: :asc) },
           class_name:  "Rubygem::DownloadStat",
           primary_key: :name,
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :trends, -> { order(date: :asc) },
           class_name:  "Rubygem::Trend",
           primary_key: :name,
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :rubygem_dependencies,
           -> { order(dependency_name: :asc) },
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  # Reverse dependencies of this gem, so gems that use this one
  # as a dependency
  has_many :reverse_dependencies,
           -> { order(rubygem_name: :asc) },
           class_name:  "RubygemDependency",
           foreign_key: :dependency_name,
           inverse_of:  :dependency,
           dependent:   :destroy

  # The corresponding ruby toolbox project record for the corresponding
  # reverse dependency rubygem
  has_many :reverse_dependency_projects,
           through:    :reverse_dependencies,
           source:     :depending_project,
           class_name: "Project"

  has_many :code_statistics,
           -> { order(language: :asc) },
           class_name:  "Rubygem::CodeStatistic",
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  scope :update_batch, lambda {
    where("fetched_at < ? ", 24.hours.ago.utc)
      .order(fetched_at: :asc)
      .limit((count / 24.0).ceil)
  }

  def url
    File.join "https://rubygems.org/gems", name
  end

  def documentation_url
    super.presence || File.join("http://www.rubydoc.info/gems", name, "frames")
  end
end
