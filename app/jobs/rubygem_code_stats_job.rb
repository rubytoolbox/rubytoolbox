# frozen_string_literal: true

#
# Retrieves and persists lines of code statistics for given rubygem name
#
class RubygemCodeStatsJob < ApplicationJob
  def perform(rubygem_name)
    rubygem = Rubygem.find rubygem_name

    statistics = fetch_stats rubygem

    statistics.each do |statistic|
      rubygem.code_statistics.find_or_initialize_by(language: statistic.language).update!(
        blanks:   statistic.blanks,
        code:     statistic.code,
        comments: statistic.comments
      )
    end

    rubygem.code_statistics.where.not(language: statistics.map(&:language)).destroy_all
  end

  private

  def fetch_stats(rubygem)
    RubygemCodeStatsService.statistics name: rubygem.name, version: rubygem.current_version
  end
end
