# frozen_string_literal: true

class Project::Order
  class Direction
    attr_accessor :group, :attribute, :direction
    attr_writer :key
    private :group=, :attribute=, :direction=, :key=

    def initialize(group, attribute, direction: :desc, key: nil)
      self.group = group.to_s
      self.attribute = attribute.to_s
      self.direction = direction.to_s.upcase
      self.key = key.to_s if key
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

  DIRECTIONS = [
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

  attr_accessor :direction
  private :direction=, :direction

  def initialize(order:)
    self.direction = DIRECTIONS.find { |d| d.key == order } || DIRECTIONS.first
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
    DIRECTIONS.group_by(&:group)
  end
end