# frozen_string_literal: true

require "rails_helper"

RSpec.describe HttpService do
  fixtures :all

  describe ".client" do
    let(:client) { described_class.client }

    it "is a MockClient in test env" do
      expect(client).to be_a described_class::MockClient
    end

    it "is an HTTP.rb client when given :real_http spec metadata", :real_http do
      expect(client).to be_a HTTP::Client
    end
  end

  describe HttpService::MockClient do
    describe "#get" do
      let(:do_get) { described_class.new.get url }

      describe "for a known url" do
        let(:url) { "https://rubygems.org/api/v1/gems/rspec.json" }

        it "returns an HTTP response" do
          expect(do_get).to be_a HTTP::Response
        end

        it "has the expected status code" do
          expect(do_get.status).to be == 200
        end

        it "has the expected body" do
          expect(Oj.load(do_get.body)).to have_key "downloads"
        end
      end

      describe "for an unknown url" do
        let(:url) { "http://www.thisisnotpartofthemocks.com" }

        it "raises an UnmockedRequestError" do
          expect { do_get }.to raise_error(described_class::UnmockedRequestError)
        end
      end
    end
  end
end
