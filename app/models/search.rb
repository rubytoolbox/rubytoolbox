# frozen_string_literal: true

class Search
  attr_accessor :query, :order, :show_forks
  private :query=, :order=, :show_forks=

  def initialize(query, order: Project::Order.new(directions: Project::Order::SEARCH_DIRECTIONS), show_forks: false)
    self.query = query.presence&.strip
    self.order = order
    self.show_forks = !!show_forks
  end

  def query?
    query.present?
  end

  def projects
    @projects ||= if ENV["NEW_SEARCH"]
                    meili_search_results
                  else
                    Project.search(query, order: order, show_forks: show_forks)
                  end
  end

  def categories
    @categories ||= Category.search(query)
  end

  private

  def meili_search_results
    permalinks = MeiliSearch.client.search :projects, query

    Project
      .where(permalink: permalinks)
      .with_score
      .with_bugfix_forks(show_forks)
      .includes_associations
      .order(Arel.sql("array_position(ARRAY[#{permalinks.map { "'#{_1}'" }.join(',')}], projects.permalink::text)"))
  end
end
