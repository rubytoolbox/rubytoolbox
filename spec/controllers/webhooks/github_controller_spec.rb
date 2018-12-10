# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::GithubController, type: :controller do
  describe "POST create" do
    let(:request_body) { { foo: :bar }.to_json }
    let(:event_name) { "page_build" }
    let(:secret) { ENV.fetch("GITHUB_WEBHOOK_SECRET") }
    let(:signature) { OpenSSL::HMAC.hexdigest OpenSSL::Digest.new("sha1"), secret, request_body }

    def do_request
      request.headers["X-GitHub-Event"] = event_name
      request.headers["Content-Type"] = "application/json"
      request.headers["X-Hub-Signature"] = "sha1=#{signature}"

      post :create, body: request_body
    end

    describe "with valid event and signature" do
      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "queues a catalog import job on valid signature and page_build event" do
        expect(CatalogImportJob).to receive(:perform_async)
        do_request
      end
    end

    describe "with invalid signature" do
      let(:signature) { "INVALID" }

      it "raises an GithubWebhook::Processor::SignatureError on invalid signature" do
        expect { do_request }.to raise_error GithubWebhook::Processor::SignatureError
      end

      it "does not queue CatalogImportJob" do
        expect(CatalogImportJob).not_to receive(:perform_async)
        begin
          do_request
        rescue GithubWebhook::Processor::SignatureError
          "this is fine"
        end
      end
    end

    describe "with invalid event" do
      let(:event_name) { "cupcake!!!" }

      it "raises UnsupportedEventError" do
        expect { do_request }.to raise_error GithubWebhook::Processor::UnsupportedGithubEventError
      end
    end
  end
end
