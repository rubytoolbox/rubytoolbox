# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sidekiq Web" do
  fixtures :all

  shared_examples_for "an unauthenticated response" do
    it "returns an empty body" do
      expect(page.body).to be_empty
    end

    it "responds with status 401" do
      expect(page.status_code).to eq 401
    end
  end

  describe "with invalid password" do
    before do
      page.driver.browser.authorize "name", "thisisinvalid"
      visit "/ops/sidekiq"
    end

    it_behaves_like "an unauthenticated response"
  end

  describe "without password" do
    before do
      visit "/ops/sidekiq"
    end

    it_behaves_like "an unauthenticated response"
  end

  describe "with valid password" do
    before do
      page.driver.browser.authorize "name", ENV.fetch("SIDEKIQ_PASSWORD", nil)
      visit "/ops/sidekiq"
    end

    it "shows the sidekiq dashboard" do
      within ".navbar-brand" do
        expect(page).to have_text "Sidekiq"
      end
    end
  end
end
