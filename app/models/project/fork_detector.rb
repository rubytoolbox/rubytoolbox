# frozen_string_literal: true

#
# This class detects "bugfix forks" of gems.
#
# Before bundler it was pretty tough to include a gem including
# some additional bugfix in a project. Many people adopted the practice
# of submitting the bugfix PR, and in the meantime published their own
# version of the gem to rubygem with a namespace.
#
# Those gems quite commonly still reference the original upstream
# github repo, leading to high project popularity scores and polluting
# search results (they mostly have very few downloads and a single or
# extremely few releases)
#
# The checks in here apply some checks derived from real world data
# that identify those projects so they can be flagged accordingly.
#
class Project::ForkDetector
  class Check
    attr_accessor :name, :check
    private :name=, :check=

    def initialize(name, &check)
      self.name = name.to_s
      self.check = check
    end

    def applies?(project)
      check.call project
    end
  end

  #
  # Quite commonly a bugfix fork keeps the original github repo
  # reference, which means the popularity score is high due to
  # popularity of the upstream repo
  #
  GithubSibling = Check.new("github_sibling") do |project|
    next unless project.github_repo_sibling_gem_with_most_downloads && project.rubygem_downloads

    sibling = project.github_repo_sibling_gem_with_most_downloads
    relative_downloads = ((project.rubygem_downloads * 100) / sibling.downloads.to_f).round(2)
    next unless relative_downloads < 1.0

    sibling.name
  end

  #
  # If the github repo reference was not set on the upstream
  # rubygem the impact on the score is not so big, yet these forks
  # can still also produce noise in search results due to matching
  # keywords in the name and description.
  #
  RubygemSibling = Check.new("rubygem_sibling") do |project|
    next unless project.rubygem_downloads

    sibling = Rubygem.where(description: project.rubygem_description).order(downloads: :desc).first

    next unless sibling

    relative_downloads = ((project.rubygem_downloads * 100) / sibling.downloads.to_f).round(2)

    next unless relative_downloads < 50

    sibling.name
  end

  FORK_CHECKS = [
    GithubSibling,
    RubygemSibling,
  ].freeze

  attr_accessor :project
  private :project=

  def initialize(project)
    self.project = project
  end

  def fork_criteria
    @fork_criteria ||= fork_matches.keys
  end

  def forked_from
    @forked_from ||= fork_matches.values.compact.first
  end

  def fork?
    fork_matches.any?
  end

  private

  def fork_matches
    @fork_matches ||= FORK_CHECKS.each_with_object({}) do |check, matches|
      result = check.applies? project
      next unless result

      matches[check.name] = result
    end
  end
end
