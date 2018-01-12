# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    @project = Project.find_for_show! params[:id]
  end
end
