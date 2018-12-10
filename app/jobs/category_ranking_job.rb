# frozen_string_literal: true

#
# Applies a ranking to categories based on the *two* most included popular projects.
#
# Two most popular because this reduces the impact of categories that only have
# a single library that is especially popular, for this ranking categories with
# multiple popular choices are more interesting, and this produced reasonable
# output when run against the actual data :)
#
class CategoryRankingJob < ApplicationJob
  def perform(limit: 16)
    top_category_ids = Set.new
    occurences = Hash.new(0)

    categorized_projects_by_score.each do |project|
      project.category_ids.each { |category_id| occurences[category_id] += 1 }
      top_category_ids += matching_occurences(occurences)

      break if top_category_ids.size >= limit
    end

    update_ranking! top_category_ids.first(limit)
  end

  private

  def categorized_projects_by_score
    @categorized_projects_by_score ||= Project.includes(:categories)
                                              .joins(:categories)
                                              .where.not(score: nil)
                                              .order(score: :desc)
  end

  def matching_occurences(occurences)
    occurences
      .select { |_, count| count > 1 }
      .map { |category_id, _| category_id }
  end

  def update_ranking!(top_category_ids)
    Category.transaction do
      Category.update_all rank: nil # rubocop:disable Rails/SkipsModelValidations
      top_category_ids.each_with_index do |category_id, rank|
        Category.find(category_id).update! rank: rank + 1
      end
    end
  end
end
