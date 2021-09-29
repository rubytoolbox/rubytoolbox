# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatalogImportJob, type: :job do
  fixtures :all

  let(:job) { described_class.new }

  describe "#perform" do
    let(:catalog_body) { Rails.root.join("lib", "base-catalog.json").read }

    def stub_response(status: 200)
      response = HTTP::Response.new(
        status:  status,
        body:    catalog_body,
        version: "1.1"
      )
      allow(job.http_client).to receive(:get).with(job.catalog_url).and_return(response)
    end

    it "fetches the catalog" do
      stub_response
      job.perform
    end

    it "raises an error when fetching fails" do
      stub_response status: 502
      expect { job.perform }.to raise_error(/response status was 502/)
    end

    it "passes the parsed body to CatalogImport.perform" do
      stub_response
      expect(CatalogImport).to receive(:perform).with(JSON.parse(catalog_body))
      job.perform
    end

    it "queues a CategoryRankingJob" do
      stub_response
      expect(CategoryRankingJob).to receive(:perform_async)
      job.perform
    end
  end
end
