# frozen_string_literal: true

require "rails_helper"

RSpec.describe Database::ExportsController do
  fixtures :all

  describe "GET selective" do
    subject(:do_request) { get :selective }

    let(:file_url) { "https://example.com/#{SecureRandom.hex(32)}" }
    let(:export) { instance_double Database::Export, file_url: }

    before do
      allow(Database::Export).to receive(:latest).and_return export
    end

    it { is_expected.to redirect_to file_url }
  end
end
