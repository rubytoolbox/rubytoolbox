# frozen_string_literal: true

class ProjectUpdateJob < ApplicationJob
  def perform(permalink)
    Project.find_or_initialize_by(permalink: permalink).tap do |project|
      project.rubygem = Rubygem.find_by(name: permalink)
      project.github_repo_path = detect_repo_path(project)&.strip&.downcase
      project.save!
    end
  end

  private

  def detect_repo_path(project)
    if project.github_only?
      project.permalink
    else
      return unless project.rubygem
      Github.detect_repo_name project.rubygem.homepage_url,
                              project.rubygem.source_code_url,
                              project.rubygem.bug_tracker_url
    end
  end
end
