# frozen_string_literal: true

class Github::Readme < ApplicationRecord
  self.primary_key = :path
  self.table_name = :github_readmes

  belongs_to :github_repo,
             primary_key: :path,
             foreign_key: :path,
             inverse_of:  :readme
end
