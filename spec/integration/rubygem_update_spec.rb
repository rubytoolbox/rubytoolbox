# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemInfoJob do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform gem_name }

  describe "for existing gem" do
    let(:gem_name) { "rspec" }

    shared_examples_for "a rubygem data update" do
      it "stores the data locally" do
        do_perform
        expect(Rubygem.find(gem_name)).to have_attributes(
          description: kind_of(String),
          downloads: (a_value > 1_000_000)
        )
      end
    end

    describe "which exists locally" do
      it_behaves_like "a rubygem data update"
    end

    describe "which does not exist locally" do
      it "creates a new record" do
        expect { do_perform }.to change { Rubygem.count }.by(1)
      end

      it_behaves_like "a rubygem data update"
    end
  end

  describe "for non-existent gem" do
    let(:gem_name) { "(foo)" }

    describe "which exists locally" do
      it "deletes the local record" do
        Rubygem.create! name: gem_name, downloads: 500
        expect { do_perform }.to change { Rubygem.count }.by(-1)
      end
    end

    describe "which does not exist locally" do
      it "does not create a record" do
        expect { do_perform }.not_to(change { Rubygem.count })
      end
    end
  end
end
