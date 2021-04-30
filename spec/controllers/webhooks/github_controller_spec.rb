# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::GithubController, type: :controller do
  describe "POST create" do
    let(:state) { :success }
    let(:branch) { "main" }

    let(:event_name) { "status" }
    let(:secret) { ENV.fetch("GITHUB_WEBHOOK_SECRET") }

    def signature
      OpenSSL::HMAC.hexdigest OpenSSL::Digest.new("sha1"), secret, request_body.to_json
    end

    def request_body
      {
        state:      state,
        branches:   [{ name: branch }],
        repository: { default_branch: "main" },
      }
    end

    def do_request
      request.headers["X-GitHub-Event"] = event_name
      request.headers["Content-Type"] = "application/json"
      request.headers["X-Hub-Signature"] = "sha1=#{signature}"

      post :create, body: request_body.to_json
    end

    describe "with valid event and signature" do
      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "queues a catalog import job on valid signature and page_build event" do
        expect(CatalogImportJob).to receive(:perform_in).with(30.seconds)
        do_request
      end
    end

    describe "with invalid signature" do
      let(:signature) { "INVALID" }

      it "raises an GithubWebhook::Processor::SignatureError on invalid signature" do
        expect { do_request }.to raise_error GithubWebhook::Processor::SignatureError
      end

      it "does not queue CatalogImportJob" do
        expect(CatalogImportJob).not_to receive(:perform_in)
        begin
          do_request
        rescue GithubWebhook::Processor::SignatureError
          "this is fine"
        end
      end
    end

    shared_examples_for "a processed but ignored payload" do
      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "does not queue CatalogImportJob" do
        expect(CatalogImportJob).not_to receive(:perform_in)
        do_request
      end
    end

    describe "with non-applicable state" do
      let(:state) { :pending }

      it_behaves_like "a processed but ignored payload"
    end

    describe "with non-applicable branch" do
      let(:branch) { :pr }

      it_behaves_like "a processed but ignored payload"
    end

    describe "with invalid event name" do
      let(:event_name) { "cupcake!!!" }

      it "raises UnsupportedEventError" do
        expect { do_request }.to raise_error GithubWebhook::Processor::UnsupportedGithubEventError
      end
    end
  end
end
