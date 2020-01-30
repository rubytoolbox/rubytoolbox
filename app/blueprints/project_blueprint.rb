# frozen_string_literal: true

class ProjectBlueprint < ApplicationBlueprint
  identifier :permalink

  # Alias for permalink just for clarity
  field(:name) { |project, _| project.permalink }

  fields :description,
         :score

  association :rubygem, blueprint: RubygemBlueprint
  association :github_repo, blueprint: GithubRepoBlueprint
  association :health, blueprint: Project::HealthBlueprint

  field :urls do |project|
    {
      homepage_url:      project.homepage_url,
      source_code_url:   project.source_code_url,
      wiki_url:          project.wiki_url,
      bug_tracker_url:   project.bug_tracker_url,
      documentation_url: project.documentation_url,
      changelog_url:     project.changelog_url,
      mailing_list_url:  project.mailing_list_url,
      # should add ruby toolbox URL here as well
    }
  end
end
