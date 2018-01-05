# frozen_string_literal: true

class ProjectScoreJob < ApplicationJob
  def perform(permalink)
    Project.find(permalink).tap do |project|
      project.update_attributes! score: score_for_project(project)
    end
  end

  private

  def score_for_project(project)
    scores = [rubygem_score(project.rubygem), github_repo_score(project.github_repo)].compact
    return if scores.empty?
    scores.sum / scores.count
  end

  def rubygem_score(rubygem)
    return unless rubygem
    rubygem.downloads * 100.0 / rubygem.class.maximum(:downloads)
  end

  def github_repo_score(github_repo)
    return unless github_repo
    (github_repo.stargazers_count + github_repo.forks_count * 5) * 100.0 /
      (github_repo.class.maximum(:stargazers_count) + github_repo.class.maximum(:forks_count) * 5)
  end
end
