# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectSearchIndexJob do
  fixtures :all

  let(:job) do
    described_class.new
  end

  let(:project) { Factories.project "example_gem", description: "Hello World" }

  let(:client) do
    instance_double MeiliSearch
  end

  before do
    allow(MeiliSearch).to receive(:client).and_return(client)
  end

  describe "#perform" do
    it "sends project data to the search index" do
      expect(client).to receive(:store_documents)
        .with(:projects, [
                {
                  id:          Digest::SHA256.hexdigest(project.permalink),
                  permalink:   project.permalink,
                  description: project.description,
                  score:       project.score,
                },
              ])

      job.perform project.permalink
    end

    it "does not send data if the project has no score" do
      expect(client).not_to receive(:store_documents)
      project.update! score: nil

      job.perform project.permalink
    end

    it "does not send data if the client is not configured" do
      allow(MeiliSearch).to receive(:client).and_return(nil)

      job.perform project.permalink
    end
  end
end
