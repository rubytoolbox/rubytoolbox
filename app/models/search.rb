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
    @projects ||= Project.search(query, order: order, show_forks: show_forks)
  end

  def categories
    @categories ||= Category.search(query)
  end
end
