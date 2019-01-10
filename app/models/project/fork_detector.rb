# frozen_string_literal: true

# r = Project.search("authentication").limit(150).map {|p| [p.permalink, Project::ForkDetector.new(p).fork_matches]}
class Project::ForkDetector
  class Check
    attr_accessor :name, :check
    private :name=, :check=

    def initialize(name, &check)
      self.name = name.to_s
      self.check = check
    end

    def applies?(project)
      !!check.call(project)
    end
  end

  GithubSibling = Check.new("github_sibling") do |project|
    if project.github_repo_maximum_sibling_downloads && project.rubygem_downloads
      sibling_max_downloads = project.github_repo_maximum_sibling_downloads
      relative_downloads = ((project.rubygem_downloads * 100) / sibling_max_downloads.to_f).round(2)

      relative_downloads < 1.0
    end
  end

  RubygemSibling = Check.new("rubygem_sibling") do |project|
    if project.rubygem_downloads
      sibling_max_downloads = Rubygem.where(description: project.rubygem_description).maximum(:downloads)
      relative_downloads = ((project.rubygem_downloads * 100) / sibling_max_downloads.to_f).round(2)

      relative_downloads < 50
    end
  end

  FORK_CRITERIA = [
    GithubSibling,
    RubygemSibling,
  ].freeze

  attr_accessor :project
  private :project=

  def initialize(project)
    self.project = project
  end

  def fork_matches
    @fork_matches ||= FORK_CRITERIA.select { |check| check.applies? project }.map(&:name)
  end

  def fork?
    fork_matches.any?
  end
end
