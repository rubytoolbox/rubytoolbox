# frozen_string_literal: true

class Api::Projects::ComparisonsController < ActionController::API
  LIMIT = 100
  before_action :verify_limit, only: %i[show]

  def show
    projects = Project.where(permalink: requested_project_permalinks)
                      .for_display(forks: true)
                      .includes_associations
                      .order(permalink: :asc)
                      .limit(LIMIT)

    render json: ProjectBlueprint.render(projects, root: :projects, root_url: request_root_url)
  end

  private

  def verify_limit
    return if requested_project_permalinks.count <= LIMIT

    response_body = {
      error_code: "too_many_projects_requested",
      message:    "Please request no more than #{LIMIT} projects per API call",
    }

    render json: response_body, status: 400
  end

  def requested_project_permalinks
    (params[:id].presence || "").split(",")
  end

  def request_root_url
    request.protocol + request.host_with_port
  end
end
