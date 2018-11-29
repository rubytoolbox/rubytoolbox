# frozen_string_literal: true

class GlobalStats
  QUANTILES = [0.0, 0.5, 0.75, 0.95, 0.99].sort.freeze

  # To be replaced in real-life with
  #
  # * Periodical task that calculates and caches the data
  # * Quick retrieval of the pre-calculated data from redis or pg
  # * Static buckets shall probably remain to ease tests
  #
  STATIC_BUCKETS = {
    rubygem_downloads: [0, 5000, 10_000, 75_000, 1_250_000],
    github_repo_stargazers_count: [0, 2, 7, 102, 772],
    github_repo_forks_count: [0, 0, 2, 21, 127],
    github_repo_watchers_count: [0, 1, 3, 21, 75],
  }.freeze

  attr_accessor :buckets
  private :buckets, :buckets=

  def initialize(buckets: STATIC_BUCKETS)
    self.buckets = buckets
  end

  def rank(metric, value)
    metric_buckets = buckets[metric.to_sym]
    return unless metric_buckets
    (metric_buckets.reverse.index { |minimum| value >= minimum } - 5) * -1
  end
end
