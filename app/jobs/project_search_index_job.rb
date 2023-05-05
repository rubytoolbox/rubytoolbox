# frozen_string_literal: true

class ProjectSearchIndexJob < ApplicationJob
  private attr_accessor :project, :client

  # Converts given project records into documents suitable for
  # the search index. This takes arbitrary sets of projects
  # to aid with bulk imports too.
  def self.index_payload(*projects)
    projects.map do |project|
      {
        # Some gem names fail to work as IDs on meilisearch,
        # so we construct a reliable one
        id:          Digest::SHA256.hexdigest(project.permalink),
        permalink:   project.permalink,
        description: project.description,
        score:       project.score,
      }
    end
  end

  delegate :index_payload, to: :class

  def perform(permalink)
    self.client = MeiliSearch.client
    return :not_configured unless client

    self.project = Project.includes_associations.find permalink
    return unless project.score

    client.store_documents :projects, index_payload(project)
  end
end
