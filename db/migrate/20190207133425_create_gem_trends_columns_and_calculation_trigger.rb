# frozen_string_literal: false

#
# This migration creates stats columns
#
class CreateGemTrendsColumnsAndCalculationTrigger < ActiveRecord::Migration[5.2]
  def up
    change_table :rubygem_download_stats, bulk: true do |t|
      t.integer :absolute_change_week, default: nil
      t.decimal :relative_change_week, default: nil

      t.integer :absolute_change_month, default: nil
      t.decimal :relative_change_month, default: nil

      t.integer :absolute_change_year, default: nil
      t.decimal :relative_change_year, default: nil
    end

    create_stats_trigger :week, 7
    create_stats_trigger :month, 28
    create_stats_trigger :year, 364
  end

  def down
    change_table :rubygem_download_stats, bulk: true do |t|
      t.remove :absolute_change_week,
               :relative_change_week,
               :absolute_change_month,
               :relative_change_month,
               :absolute_change_year,
               :relative_change_year
    end

    drop_trigger :rubygem_stats_calculation_week, :rubygem_download_stats
    drop_trigger :rubygem_stats_calculation_month, :rubygem_download_stats
    drop_trigger :rubygem_stats_calculation_year, :rubygem_download_stats
  end

  private

  def create_stats_trigger(name, distance_in_days)
    create_trigger("rubygem_stats_calculation_#{name}", compatibility: 1)
      .on(:rubygem_download_stats)
      .declare("previous_downloads int;")
      .before(:insert,
              :update,
              &difference_to_previous_trigger_sql(name, distance_in_days))
  end

  def difference_to_previous_trigger_sql(name, distance_in_days)
    lambda do
      <<~SQL
        SELECT total_downloads INTO previous_downloads
          FROM rubygem_download_stats
          WHERE
            rubygem_name = NEW.rubygem_name AND date = NEW.date - #{distance_in_days};

        IF previous_downloads IS NOT NULL THEN
          NEW.absolute_change_#{name} := NEW.total_downloads - previous_downloads;
          IF previous_downloads > 0 THEN
            NEW.relative_change_#{name} := ROUND((NEW.absolute_change_#{name} * 100.0) / previous_downloads, 2);
          END IF;
        END IF;
      SQL
    end
  end
end
