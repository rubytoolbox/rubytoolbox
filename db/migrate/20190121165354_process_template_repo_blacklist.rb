# frozen_string_literal: true

class ProcessTemplateRepoBlacklist < ActiveRecord::Migration[5.2]
  def change
    ProjectUpdateJob::TEMPLATE_REPO_BLACKLIST.each do |repo_path|
      Project.where(github_repo_path: repo_path).find_each do |project|
        ProjectUpdateJob.perform_async project.permalink
      end
    end
  end
end
