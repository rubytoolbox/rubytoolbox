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

  def self.find_for_show!(permalink)
    includes(:category_group, projects: %i[rubygem]).find(permalink)
  end
end
