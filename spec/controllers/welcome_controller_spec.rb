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
  end
end
