# frozen_string_literal: true

#
# Just copied over from CreateGemTrendsColumnsAndCalculationTrigger migration,
# but with bigint as the type for the downloads input as the max downloads count value
# exceeded the 4-byte integer column type
#
class AdjustTrendsTriggerToBigint < ActiveRecord::Migration[7.1]
  def up
    drop_trigger :rubygem_stats_calculation_month, :rubygem_download_stats
    create_stats_trigger :month, 28
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_stats_trigger(name, distance_in_days)
    create_trigger("rubygem_stats_calculation_#{name}", compatibility: 1)
      .on(:rubygem_download_stats)
      .declare("previous_downloads bigint; previous_relative_change decimal;")
      .before(:insert,
              :update,
              &difference_to_previous_trigger_sql(name, distance_in_days))
  end

  def difference_to_previous_trigger_sql(name, distance_in_days)
    lambda do
      <<~SQL.squish
        SELECT total_downloads, relative_change_#{name} INTO previous_downloads, previous_relative_change
          FROM rubygem_download_stats
          WHERE
            rubygem_name = NEW.rubygem_name AND date = NEW.date - #{distance_in_days};

        IF previous_downloads IS NOT NULL THEN
          NEW.absolute_change_#{name} := NEW.total_downloads - previous_downloads;
          IF previous_downloads > 0 THEN
            NEW.relative_change_#{name} := ROUND((NEW.absolute_change_#{name} * 100.0) / previous_downloads, 2);

            IF previous_relative_change IS NOT NULL THEN
              NEW.growth_change_#{name} := NEW.relative_change_#{name} - previous_relative_change;
            END IF;
          END IF;
        END IF;
      SQL
    end
  end
end
