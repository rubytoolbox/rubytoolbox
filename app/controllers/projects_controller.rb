# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :find_project

  def show
    redirect_to "/projects/#{@project.permalink}" if @project.permalink != params[:id]

    @dependencies = RubygemDependency.for_project @project
  end

  def reverse_dependencies
    @display_mode = DisplayMode.new params[:display], default: "compact"

    @dependencies = @project
                    .reverse_dependencies
                    .includes_associations
                    .with_bugfix_forks(show_forks?)
                    .order("score DESC NULLS LAST")
                    .page(params[:page])
  end

  private

  def find_project
    @project = Project.strict_loading.find_for_show! params[:id]
  end

  def show_forks?
    params[:show_forks].present? && params[:show_forks] == "true"
  end
  helper_method :show_forks?

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::DEFAULT_DIRECTIONS
  end
  helper_method :current_order
end
