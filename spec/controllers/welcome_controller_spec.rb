# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeController, type: :controller do
  describe "GET home" do
    let(:do_request) { get :home }

    it "responds with success" do
      expect(do_request).to be_successful
    end

    it "renders template home" do
      expect(do_request).to render_template :home
    end

    it "assigns CategoryGroup.for_welcome_page" do
      allow(CategoryGroup).to receive(:for_welcome_page).and_return("The Groups")
      do_request
      expect(assigns(:groups)).to be == "The Groups"
    end
  end
end
