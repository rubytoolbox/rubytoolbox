# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  fixtures :all

  controller do
    def index
      respond_to do |f|
        f.html { render text: "Hello World" }
      end
    end
  end

  describe "requesting an invalid format" do
    def do_request
      get :index, format: :json
    end

    it "renders 404 page" do
      do_request

      expect(response).to have_http_status(:not_found)
        .and have_attributes(
          body: Rails.public_path.join("404.html").read
        )
    end
  end
end
