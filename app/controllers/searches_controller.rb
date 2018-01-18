# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:query].presence
    @projects = Project.search(params[:query]).limit(20) if @query
  end
end
