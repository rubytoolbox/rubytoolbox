# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    @projects = Project.search(@query).limit(20) if @query
  end
end
