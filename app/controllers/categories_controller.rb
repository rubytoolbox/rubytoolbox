# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.find_for_show! params[:id]
    redirect_to @category if @category.permalink != params[:id]
  end
end
