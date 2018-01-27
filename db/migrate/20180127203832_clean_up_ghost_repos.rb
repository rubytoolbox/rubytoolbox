# frozen_string_literal: true

class CleanUpGhostRepos < ActiveRecord::Migration[5.1]
  # See https://github.com/rubytoolbox/rubytoolbox/pull/107
  # and https://github.com/rubytoolbox/catalog/pull/26
  def change
    Project.where(rubygem_name: nil, score: nil).destroy_all
  end
end
