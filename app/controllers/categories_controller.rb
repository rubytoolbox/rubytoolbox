# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @groups = CategoryGroup.for_welcome_page
  end

  def show
    @category = Category.find_for_show! params[:id], order: current_order
    @display_mode = DisplayMode.new params[:display]
    redirect_to @category if @category.permalink != params[:id]
  end

  private

  def display_mode
    @display_mode ||= DisplayMode.new params[:display]
  end
  helper_method :display_mode

  def current_order
    @current_order ||= Project::Order.new order: params[:order]
  end
  helper_method :current_order
end
