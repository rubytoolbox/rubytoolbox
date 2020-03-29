# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
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

    it "raises a routing error, which will show 404 page on production" do
      expect { do_request }.to raise_error(ActionController::RoutingError, %r{Unknown path /anonymous.json})
    end
  end
end
