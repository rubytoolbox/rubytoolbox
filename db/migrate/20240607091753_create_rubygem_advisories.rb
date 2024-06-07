# frozen_string_literal: true

class CreateRubygemAdvisories < ActiveRecord::Migration[7.1]
  def change
    create_table :rubygem_advisories do |t|
      t.string :rubygem_name, null: false
      t.string :identifier, null: false
      t.date :date, null: false
      t.jsonb :advisory_data, null: false, default: {}
      t.timestamps
    end

    add_foreign_key :rubygem_advisories, :rubygems, column: :rubygem_name, primary_key: :name

    add_index :rubygem_advisories, %i[rubygem_name identifier], unique: true

    # Queue the first data sync right away
    RubygemAdvisoriesSyncJob.perform_in 2.minutes
  end
end
