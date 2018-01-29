# frozen_string_literal: true

class Search
  attr_accessor :query
  private :query=

  def initialize(query)
    self.query = query.presence&.strip
  end

  def query?
    query.present?
  end

  def projects
    @projects ||= Project.search(query)
  end

  def categories
    @categories ||= Category.search(query)
  end
end
