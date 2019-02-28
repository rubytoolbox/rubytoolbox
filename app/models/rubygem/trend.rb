# frozen_string_literal: true

class Rubygem::Trend < ApplicationRecord
  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :trends

  belongs_to :rubygem_download_stat,
             class_name: "Rubygem::DownloadStat"

  has_one :project, through: :rubygem
  has_one :github_repo, through: :project

  delegate :absolute_change_month,
           :relative_change_month,
           :growth_change_month,
           to: :rubygem_download_stat

  def self.with_associations
    includes(:rubygem_download_stat, project: %i[rubygem github_repo])
      .joins(:rubygem_download_stat, project: %i[rubygem github_repo])
  end

  def self.latest
    for_date maximum(:date)
  end

  def self.for_date(date)
    where(date: date)
      .with_associations
      .order(position: :asc)
  end
end
