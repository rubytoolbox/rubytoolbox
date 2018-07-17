# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable - Legacy Migration
class ChangeCategoriesAndGithubRepoPrimaryKeysToCitext < ActiveRecord::Migration[5.1]
  def up
    enable_extension "citext"

    remove_foreign_key :categories, column: :category_group_permalink, primary_key: :permalink
    remove_foreign_key :categorizations,
                       column: :category_permalink,
                       primary_key: :permalink

    change_column :category_groups, :permalink, :citext, null: false

    change_column :categories, :permalink, :citext, null: false
    change_column :categories, :category_group_permalink, :citext, null: false

    change_column :categorizations, :category_permalink, :citext, null: false

    add_foreign_key :categories, :category_groups, column: :category_group_permalink, primary_key: :permalink
    add_foreign_key :categorizations, :categories,
                    column: :category_permalink,
                    primary_key: :permalink

    change_column :github_repos, :path, :citext, null: false
    change_column :projects, :github_repo_path, :citext
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
# rubocop:enable Rails/BulkChangeTable
