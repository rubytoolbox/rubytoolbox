# frozen_string_literal: true

class Category < ApplicationRecord
  self.primary_key = :permalink

  belongs_to :category_group,
             primary_key: :permalink,
             foreign_key: :category_group_permalink
end
