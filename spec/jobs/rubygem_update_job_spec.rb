# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemUpdateJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform gem_name }
  let(:gem_name) { "rspec" }

  describe "#perform" do
    let(:expected_attributes) do
      {
        authors: "Steven Baker, David Chelimsky, Myron Marston",
        bug_tracker_url: nil,
        current_version: "3.7.0",
        documentation_url: "http://relishapp.com/rspec",
        downloads: 145_999_055,
        homepage_url: "http://github.com/rspec",
        licenses: %w[MIT],
        mailing_list_url: "http://rubyforge.org/mailman/listinfo/rspec-users",
        name: "rspec",
        source_code_url: "http://github.com/rspec/rspec",
        wiki_url: nil,
      }
    end

    it "applies the remote info attributes" do
      do_perform

      expect(Rubygem.find(gem_name)).to have_attributes(expected_attributes)
    end

    describe "when rubygems.org is down" do
      let(:gem_name) { "thisisdowninmock" }

      it "raises an exception" do
        expect { do_perform }.to raise_error "Unknown response status 500"
      end
    end
  end
end
