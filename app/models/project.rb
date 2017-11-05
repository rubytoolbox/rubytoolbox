# frozen_string_literal: true

class Project < ApplicationRecord
  self.primary_key = :permalink

  has_many :categorizations,
           primary_key: :permalink,
           foreign_key: :project_permalink,
           validate:    false,
           dependent:   :destroy

  has_many :categories, through: :categorizations

  def description
    Forgery(:lorem_ipsum).words(20 + rand(20))
  end

  def score
    rand(100).round(2)
  end
end
