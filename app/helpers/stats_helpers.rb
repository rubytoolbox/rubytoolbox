# frozen_string_literal: true

module StatsHelpers
  #
  # Fetches the values needed to be within the 0...100th percentiles
  # of the given table/column combination.
  #
  def percentiles(table, column)
    groups = (0..100).map { |n| n / 100.0 }

    query = <<~SQL
      SELECT unnest(percentile_disc(array[#{groups.join(',')}])
        WITHIN GROUP (ORDER BY #{column} ASC))
      FROM #{table}
      WHERE #{column} IS NOT NULL
    SQL

    ApplicationRecord.connection.execute(query).each_with_index
                     .map { |result, i| ["#{i}%", result["unnest"]] }
                     .to_h
  end

  #
  # Fetches counts of occurences per year for given table/column combination
  #
  def date_groups(table, column)
    query = <<~SQL
      SELECT date_trunc('year', #{column}) AS year, count(*) as events
        FROM #{table}
      WHERE #{column} IS NOT NULL
      GROUP BY year
      ORDER BY year ASC
    SQL

    ApplicationRecord.connection.execute(query)
                     .map { |row| [Date.parse(row["year"]).year, row["events"]] }
                     .to_h
  end
end
