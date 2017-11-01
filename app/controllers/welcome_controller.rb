# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    @groups = CategoryGroup.for_welcome_page
    render action: :home
  end
end
