# frozen_string_literal: true

class CategoryGroup < ApplicationRecord
  self.primary_key = :permalink

  has_many :categories,
           -> { order(name: :asc) },
           foreign_key: :category_group_permalink,
           dependent: :destroy
end
