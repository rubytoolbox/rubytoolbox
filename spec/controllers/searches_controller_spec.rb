# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController, type: :controller do
  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to be_successful
    end
  end
end
