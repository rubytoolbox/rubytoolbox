# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::Health do
  fixtures :all

  def status(key: :healthy, level: :green, icon: :heartbeat, &block)
    Project::Health::Status.new key, level, icon, &block
  end

  let(:health) { described_class.new(project) }
  let(:project) { instance_double(Project) }

  describe described_class::Status do
    it "raises an error when for an invalid level" do
      expect { status(level: :purple) }.to raise_error ArgumentError, /Unknown level purple/
    end

    it "raises an error when for an unknown i18n key" do
      expect { status(key: :foobar) }.to raise_error I18n::MissingTranslation
    end

    describe "#label" do
      it "is the translated label for given key" do
        expect(status.label).to be == I18n.t("project_health.healthy")
      end
    end

    describe "#icon" do
      it "is set to the passed value" do
        expect(status.icon).to be == :heartbeat
      end
    end

    describe "#applies?" do
      it "is true when the given argument causes the block to return truthy value" do
        check = status { |p| p == 1 }
        expect(check.applies?(1)).to be true
      end

      it "is false when the given argument causes the block to return falsy value" do
        check = status { |p| p == 2 }
        expect(check.applies?(1)).to be false
      end
    end
  end

  describe "#checks" do
    it "defaults to #{described_class}::Checks::ALL" do
      expect(health.checks).to be described_class::Checks::ALL
    end
  end

  describe "#status" do
    it "passes the given project to all checks" do
      expect(health.checks).to all(receive(:applies?).with(project))
      health.status
    end

    it "contains any matching checks" do
      health.checks.each { |check| allow(check).to receive(:applies?) }
      checks = health.checks.sample(3)
      checks.each { |check| allow(check).to receive(:applies?).and_return(true) }
      expect(health.status.map(&:key).sort).to be == checks.map(&:key).sort
    end

    it "contains HEALTHY_STATUS if no other checks apply" do
      health.checks.each { |check| allow(check).to receive(:applies?) }
      expect(health.status).to be == [described_class::HEALTHY_STATUS]
    end
  end

  describe "overall_level" do
    before do
      health.checks.each { |check| allow(check).to receive(:applies?) }
    end

    it "returns the red if a matching check is red" do
      health.checks.each { |check| allow(check).to receive(:applies?).and_return(true) }
      expect(health.overall_level).to be == :red
    end

    it "returns yellow if worst matching check is yellow" do
      relevant_levels = %i[yellow green]
      health.checks.each do |check|
        next unless relevant_levels.include? check.level

        allow(check).to receive(:applies?).and_return(true)
      end
      expect(health.overall_level).to be == :yellow
    end

    it "returns green if worst matching check is green" do
      health.checks.each do |check|
        next unless check.level == :green

        allow(check).to receive(:applies?).and_return(true)
      end
      expect(health.overall_level).to be == :green
    end
  end
end
