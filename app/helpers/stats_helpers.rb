# frozen_string_literal: true

module StatsHelpers
  #
  # Fetches the values needed to be within the 0...100th percentiles
  # of the given table/column combination.
  #
  def percentiles(table, column)
    groups = (0..100).map { |n| n / 100.0 }

    query = <<~SQL.squish
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
  def date_groups(table, column) # rubocop:disable Metrics/MethodLength
    query = <<~SQL.squish
      SELECT date_trunc('year', #{column}) AS year, count(*) as events
        FROM #{table}
      WHERE #{column} IS NOT NULL
      GROUP BY year
      ORDER BY year ASC
    SQL

    ApplicationRecord.connection.execute(query)
                     .map { |row| [Date.parse(row["year"]).year, row["events"]] }
                     .select { |row| (2004..Time.current.year).cover? row.first }
                     .to_h
  end

  #
  # For a given hash this crops all but the last leading keys
  # that has a value of 0. This is helpful for removing "padding"
  # from a collection of percentiles where the first batch of them
  # might be 0
  #
  def crop_zero_values(hash)
    array = hash.to_a.reverse
    last_zero_value = array.find_index { |el| el.last.to_i.zero? }
    array[0..last_zero_value].reverse.to_h
  end
end
