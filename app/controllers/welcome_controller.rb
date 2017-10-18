# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    render action: :home
  end
end
