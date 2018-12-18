# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#project_metrics" do
    let(:project) { instance_double(Project, rubygem_downloads: 22_123_122) }
    let(:project_metrics) { helper.project_metrics(project, :rubygem_downloads) }

    it "renders the expected label" do
      expect(project_metrics).to include("<span>Downloads</span>")
    end

    it "renders the given icon" do
      expect(project_metrics).to include("<i class=\"fa fa-download\"></i>")
    end

    it "renders the given, pretty-printed value" do
      expect(project_metrics).to include("<strong>22,123,122</strong>")
    end

    it "does not pretty-print when the value is not an integer" do
      allow(project).to receive(:rubygem_downloads).and_return("Hello")
      expect(project_metrics).to include "<strong>Hello</strong>"
    end

    it "renders only the container when the value is blank" do
      allow(project).to receive(:rubygem_downloads)
      expect(project_metrics).to be == "<div class=\"metric\"></div>"
    end
  end

  describe "#title" do
    it "is the site name and tagline by default" do
      expect(helper.title).to be == [helper.site_name, helper.tagline].join(" - ")
    end

    it "uses the content_for title if present and appends site name" do
      helper.content_for(:title) { "My content" }
      expect(helper.title).to be == ["My content", helper.site_name].join(" - ")
    end

    it "returns default title even when given when default: true" do
      helper.content_for(:title) { "My content" }
      expect(helper.title(default: true)).to be == [helper.site_name, helper.tagline].join(" - ")
    end
  end

  describe "#description" do
    it "comes from i18n by default" do
      expect(helper.description).to be == I18n.t(:description)
    end

    it "can be customized using content_for" do
      helper.content_for(:description) { "Some other text" }
      expect(helper.description).to be == "Some other text"
    end
  end

  describe "#recent_distance_in_words" do
    {
      3.days               => "within last week",
      6.days               => "within last week",
      7.days - 2.seconds   => "within last week",
      7.days               => "within last two weeks",
      14.days - 2.seconds  => "within last two weeks",
      15.days              => "within last month",
      1.month - 2.seconds  => "within last month",
      1.month              => "within last 3 months",
      3.months - 2.seconds => "within last 3 months",
      3.months             => "within last year",
      1.year - 2.seconds   => "within last year",
      1.year               => "within last 2 years",
      2.years - 2.seconds  => "within last 2 years",
      2.years              => "more than 2 years ago",
      10.years             => "more than 2 years ago",
      nil                  => nil,
      ""                   => nil,
      " "                  => nil,
    }.each do |time, expected_result|
      it "is #{expected_result.inspect} for #{time.try(:ago).inspect}" do
        expect(helper.recent_distance_in_words(time.try(:ago))).to be == expected_result
      end
    end
  end

  describe "#active_when" do
    it "is 'is-active' when given controller matches current controller name" do
      expect(helper.active_when(controller: "test")).to be == "is-active"
    end

    it "is 'is-active' when matching controller is given as symbol" do
      expect(helper.active_when(controller: :test)).to be == "is-active"
    end

    it "is nil when given controller name does not match current controller name" do
      expect(helper.active_when(controller: "foo")).to be nil
    end
  end
end
