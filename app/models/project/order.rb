# frozen_string_literal: true

class Project::Order
  class Direction
    attr_accessor :group, :attribute, :direction
    attr_writer :key, :sql
    private :group=, :attribute=, :direction=, :key=, :sql=

    def initialize(group, attribute, direction: :desc, key: nil, sql: nil)
      self.group = group.to_s
      self.attribute = attribute.to_s
      self.direction = direction.to_s.upcase
      self.key = key.to_s if key
      self.sql = sql
    end

    def key
      @key ||= [group, attribute].join("_")
    end

    def sql
      @sql ||= "#{table_name}.#{attribute} #{direction} NULLS LAST"
    end

    private

    def table_name
      group.pluralize
    end
  end

  DEFAULT_DIRECTIONS = [
    Direction.new(:project, :score, key: :score),
    Direction.new(:rubygem, :downloads),
    Direction.new(:rubygem, :first_release_on, direction: :asc),
    Direction.new(:rubygem, :latest_release_on),
    Direction.new(:rubygem, :releases_count),
    Direction.new(:rubygem, :reverse_dependencies_count),
    Direction.new(:github_repo, :stargazers_count),
    Direction.new(:github_repo, :forks_count),
    Direction.new(:github_repo, :watchers_count),
    Direction.new(:github_repo, :average_recent_committed_at),
  ].freeze

  PG_SEARCH_RANK_DIRECTION = Direction.new(
    :project,
    :rank,
    key: :rank,
    sql: "#{PgSearch::Configuration.alias('projects')}.rank DESC NULLS LAST"
  )
  SEARCH_DIRECTIONS = [PG_SEARCH_RANK_DIRECTION] + DEFAULT_DIRECTIONS

  attr_accessor :direction, :directions
  private :direction=, :direction, :directions=, :directions

  def initialize(order: nil, directions: DEFAULT_DIRECTIONS)
    self.directions = directions
    self.direction = directions.find { |d| d.key == order } || default_direction
  end

  def ordered_by
    direction.key
  end

  # Shorthand to check if given order is the current one
  def is?(order)
    ordered_by == order
  end

  def sql
    direction.sql
  end

  def available_groups
    directions.group_by(&:group)
  end

  def default_direction?
    direction == default_direction
  end

  private

  def default_direction
    directions.first
  end
end
