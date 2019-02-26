# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeController, type: :controller do
  render_views

  describe "GET home" do
    let(:do_request) { get :home }

    it "responds with success" do
      expect(do_request).to be_successful
    end

    it "renders template home" do
      expect(do_request).to render_template :home
    end

    it "assigns featured categories" do
      collection = Category.limit(3)
      allow(Category).to receive(:featured).and_return(collection)
      do_request
      expect(assigns(:featured_categories)).to be collection
    end

    it "assigns a Stats instance" do
      stats = instance_double Stats
      allow(Stats).to receive(:new).and_return(stats)
      do_request
      expect(assigns(:stats)).to be stats
    end
  end
end
