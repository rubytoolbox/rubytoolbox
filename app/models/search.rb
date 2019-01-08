# frozen_string_literal: true

class Search
  attr_accessor :query, :order
  private :query=, :order=

  def initialize(query, order: Project::Order.new(directions: Project::Order::SEARCH_DIRECTIONS))
    self.query = query.presence&.strip
    self.order = order
  end

  def query?
    query.present?
  end

  def projects
    @projects ||= Project.search(query, order: order)
  end

  def categories
    @categories ||= Category.search(query)
  end
end
