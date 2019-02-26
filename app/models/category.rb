# frozen_string_literal: true

class Category < ApplicationRecord
  self.primary_key = :permalink

  belongs_to :category_group,
             primary_key: :permalink,
             inverse_of:  :categories,
             foreign_key: :category_group_permalink

  has_many :categorizations,
           primary_key: :permalink,
           foreign_key: :category_permalink,
           inverse_of:  :category,
           dependent:   :destroy

  has_many :projects, -> { order(score: :desc) },
           through: :categorizations

  scope :by_rank, -> { where.not(rank: nil).order(rank: :asc) }
  scope :featured, -> { by_rank.limit(16).includes(:projects) }

  include PgSearch
  pg_search_scope :search_scope,
                  against:   %i[name_tsvector description_tsvector],
                  using:     {
                    tsearch: {
                      tsvector_column: %w[name_tsvector description_tsvector],
                      prefix:          true,
                      dictionary:      "simple",
                    },
                  },
                  ranked_by: ":tsearch"

  def self.search(query)
    includes(:projects).search_scope(query)
  end

  def self.find_for_show!(permalink, order: Project::Order.new)
    includes(:category_group, projects: %i[rubygem github_repo])
      .order(order.sql)
      .find(permalink.try(:strip))
  end

  CATALOG_GITHUB_BASE_URL = "https://github.com/rubytoolbox/catalog/"

  def catalog_show_url
    catalog_github_url
  end

  def catalog_edit_url
    catalog_github_url edit: true
  end

  private

  def catalog_github_url(edit: false)
    type = edit ? "edit" : "tree"
    File.join CATALOG_GITHUB_BASE_URL, type, "master/catalog", category_group.permalink, "#{permalink}.yml"
  end
end
