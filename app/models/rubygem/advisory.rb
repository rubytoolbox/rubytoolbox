# frozen_string_literal: true

class Rubygem::Advisory < ApplicationRecord
  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :advisories

  validates :date, presence: true
  validates :rubygem_name, presence: true
end
