# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    @project = Project.find_for_show! params[:id]
    redirect_to @project if @project.permalink != params[:id]
  end
end
