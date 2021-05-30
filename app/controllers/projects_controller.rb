# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    @project = Project.strict_loading.find_for_show! params[:id]
    redirect_to "/projects/#{@project.permalink}" if @project.permalink != params[:id]

    @dependencies = RubygemDependency.for_project @project
  end
end
