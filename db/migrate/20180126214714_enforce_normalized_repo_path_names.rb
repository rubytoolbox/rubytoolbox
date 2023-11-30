# frozen_string_literal: true

class EnforceNormalizedRepoPathNames < ActiveRecord::Migration[5.1]
  # See https://github.com/rubytoolbox/rubytoolbox/pull/103
  def change
    Project.where(rubygem_name: nil).find_each do |project|
      current_permalink = project.permalink
      normalized_permalink = Github.normalize_path current_permalink
      next if current_permalink == normalized_permalink

      # Extra incantation to ensure referential integrity
      Project.transaction do
        categories = project.categories.to_a
        project.update! categories: []
        project.update! permalink: normalized_permalink
        project.update! categories:
      end
    end
  end
end
