# frozen_string_literal: true

class Category < ApplicationRecord
  self.primary_key = :permalink

  belongs_to :category_group,
             primary_key: :permalink,
             inverse_of: :categories,
             foreign_key: :category_group_permalink

  has_many :categorizations,
           primary_key: :permalink,
           foreign_key: :category_permalink,
           inverse_of:  :category,
           dependent:   :destroy

  has_many :projects, -> { order(score: :desc) },
           through: :categorizations

  include PgSearch
  pg_search_scope :search_scope,
                  against: :name_tsvector,
                  using: {
                    tsearch: {
                      tsvector_column: %w[name_tsvector],
                      prefix: true,
                      dictionary: "simple",
                    },
                  },
                  ranked_by: ":tsearch"

  def self.search(query)
    search_scope(query)
  end

  def self.find_for_show!(permalink)
    includes(:category_group, projects: %i[rubygem github_repo]).find(permalink)
  end
end
