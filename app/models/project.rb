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

  def description
    Forgery(:lorem_ipsum).words(rand(20..39))
  end

  def score
    rand(100).round(2)
  end
end
