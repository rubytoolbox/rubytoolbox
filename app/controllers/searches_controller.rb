# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    @search = Search.new(@query) if @query
  end
end
