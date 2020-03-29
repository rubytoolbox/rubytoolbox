# frozen_string_literal: true

class Api::Projects::ComparisonsController < ActionController::API
  def show
    projects = Project.where(permalink: requested_project_permalinks)
                      .for_display(forks: true)
                      .includes_associations
                      .order(permalink: :asc)
                      .limit(100)

    render json: ProjectBlueprint.render(projects, root: :projects, root_url: request_root_url)
  end

  private

  def requested_project_permalinks
    (params[:id].presence || "").split(",")
  end

  def request_root_url
    request.protocol + request.host_with_port
  end
end
