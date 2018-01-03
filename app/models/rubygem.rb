# frozen_string_literal: true

class Rubygem < ApplicationRecord
  self.primary_key = :name

  has_one :project,
          primary_key: :name,
          foreign_key: :rubygem_name,
          inverse_of: :rubygem,
          dependent: :destroy
end
