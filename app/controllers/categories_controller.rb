# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @groups = CategoryGroup.for_welcome_page
  end

  def show
    @category = Category.find_for_show! params[:id], order: current_order
    @display_mode = display_mode
    redirect_to @category if @category.permalink != params[:id]
  end

  private

  def display_mode
    default = browser.device.mobile? ? "compact" : "full"
    DisplayMode.new params[:display], default:
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order]
  end
  helper_method :current_order
end
