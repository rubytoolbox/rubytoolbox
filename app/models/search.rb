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
      .order(meili_order_sql(permalinks))
  end

  def meili_order_sql(permalinks)
    #
    # When we want to order by search index result rank we give postgres
    # a custom sorting based on the array position of permalink in search results
    #
    # This is a temporary solution while the new meili search index is still
    # experimental, later on this should then be somehow included in the order
    # class properly as pg search itself gets removed from the codebase.
    #
    if order.sql == Project::Order::PG_SEARCH_RANK_DIRECTION.sql
      mapped = permalinks.map { Project.connection.quote _1 }.join(",")
      Arel.sql("array_position(ARRAY[#{mapped}], projects.permalink::text)")
    else
      order.sql
    end
  end
end
