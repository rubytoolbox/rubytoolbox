# frozen_string_literal: true

class CategoryGroup < ApplicationRecord
  self.primary_key = :permalink

  has_many :categories,
           -> { order(name: :asc) },
           foreign_key: :category_group_permalink,
           inverse_of: :category_group,
           dependent: :destroy

  def self.for_welcome_page
    order(name: :asc).includes(:categories)
  end
end
