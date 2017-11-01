# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.find_for_show! params[:id]
  end
end
