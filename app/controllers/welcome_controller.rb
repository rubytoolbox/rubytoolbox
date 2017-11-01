# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    @groups = CategoryGroup.order(name: :asc).includes(:categories)
    render action: :home
  end
end
