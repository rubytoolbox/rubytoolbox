# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectUpdateJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform permalink }
  let(:permalink) { "rspec" }

  describe "#perform" do
    it "creates the project if not existent yet" do
      expect { do_perform }.to change { Project.find_by(permalink: permalink) }
        .from(nil).to(kind_of(Project))
    end

    it "does not create another project if present" do
      Project.create! permalink: permalink
      expect { do_perform }.not_to(change { Project.count })
    end

    it "assigns an existing gem if matching" do
      project = Project.create! permalink: permalink
      RubygemUpdateJob.new.perform(permalink)
      rubygem = Rubygem.find(permalink)
      expect { do_perform }.to change { project.reload.rubygem }.from(nil).to(rubygem)
    end

    it "assigns a github_repo_path if detected in gem urls" do
      project = Project.create! permalink: permalink
      RubygemUpdateJob.new.perform(permalink)
      expect { do_perform }.to change { project.reload.github_repo_path }.from(nil).to("rspec/rspec")
    end

    describe "for github-only project" do
      let(:permalink) { "RSPEC/RsPeC" } # Also verify downcasing / normalization work

      it "assigns permalink as the github_repo_path for github-only projects" do
        project = Project.create! permalink: permalink
        expect { do_perform }.to change { project.reload.github_repo_path }.from(nil).to("rspec/rspec")
      end
    end
  end
end
