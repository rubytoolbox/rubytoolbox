# frozen_string_literal: true

#
# See https://github.com/rubytoolbox/rubytoolbox/pull/432 for more details
#
class SimplifyGemTrendsStats < ActiveRecord::Migration[5.2]
  def up
    drop_trigger :rubygem_stats_calculation_week, :rubygem_download_stats
    drop_trigger :rubygem_stats_calculation_year, :rubygem_download_stats

    change_table :rubygem_download_stats, bulk: true do |t|
      t.remove :absolute_change_week,
               :relative_change_week,
               :growth_change_week,
               :absolute_change_year,
               :relative_change_year,
               :growth_change_year
    end
  end

  def down
    # It's actually reversible, but you'd have to figure out the `up` path from
    # 20190207133425, and it's not worth the hassle ;)
    raise ActiveRecord::IrreversibleMigration
  end
end
