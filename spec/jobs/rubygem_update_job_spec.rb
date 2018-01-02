# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemUpdateJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform gem_name }
  let(:gem_name) { "rspec" }

  describe "#perform" do
    it "applies the remote info attributes" do
      do_perform

      expect(Rubygem.find(gem_name)).to have_attributes(
        name: "rspec",
        downloads: 145_999_055
      )
    end
  end
end
