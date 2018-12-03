# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemUpdateJob, :real_http do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform gem_name }

  describe "for existing gem", vcr: { cassette_name: :thread_safe_gem } do
    let(:gem_name) { "thread_safe" }

    shared_examples_for "a rubygem data update" do
      it "stores the data locally" do
        do_perform
        expect(Rubygem.find(gem_name)).to have_attributes(
          description:                kind_of(String),
          downloads:                  (a_value > 1_000_000),
          first_release_on:           (a_value > Date.new(2012, 4, 25)),
          latest_release_on:          (a_value > Date.new(2017, 2, 21)),
          reverse_dependencies_count: (a_value > 50),
          releases_count:             (a_value > 20)
        )
      end
    end

    describe "which exists locally" do
      it_behaves_like "a rubygem data update"
    end

    describe "which does not exist locally" do
      it "creates a new record" do
        expect { do_perform }.to change(Rubygem, :count).by(1)
      end

      it_behaves_like "a rubygem data update"
    end
  end

  describe "for non-existent gem", vcr: { cassette_name: :unknown_gem } do
    let(:gem_name) { "(foo)" }

    describe "which exists locally" do
      it "deletes the local record" do
        Rubygem.create! name: gem_name, downloads: 500, current_version: "123"
        expect { do_perform }.to change(Rubygem, :count).by(-1)
      end
    end

    describe "which does not exist locally" do
      it "does not create a record" do
        expect { do_perform }.not_to(change(Rubygem, :count))
      end
    end
  end
end
