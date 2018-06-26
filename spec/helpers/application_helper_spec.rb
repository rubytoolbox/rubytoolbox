# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#metric" do
    let(:metric) { helper.metric("FooBar", 22_123_122, icon: "download") }

    it "renders the given label" do
      expect(metric).to include("<span>FooBar</span>")
    end

    it "renders the given icon" do
      expect(metric).to include("<i class=\"fa fa-download\"></i>")
    end

    it "renders the given, pretty-printed value" do
      expect(metric).to include("<strong>22,123,122</strong>")
    end

    it "does not pretty-print when the value is not an integer" do
      expect(helper.metric("FooBar", "Hello", icon: "star")).to include "<strong>Hello</strong>"
    end

    it "renders only the container when the value is blank" do
      expect(helper.metric("FooBar", "", icon: "star")).to be == "<div class=\"metric\"></div>"
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
      3.days => "within last week",
      6.days => "within last week",
      7.days - 2.seconds => "within last week",
      7.days => "within last two weeks",
      14.days - 2.seconds => "within last two weeks",
      15.days => "within last month",
      1.month - 2.seconds => "within last month",
      1.month => "within last 3 months",
      3.months - 2.seconds => "within last 3 months",
      3.months => "within last year",
      1.year - 2.seconds => "within last year",
      1.year => "within last 2 years",
      2.years - 2.seconds => "within last 2 years",
      2.years => "more than 2 years ago",
      10.years => "more than 2 years ago",
      nil => nil,
      "" => nil,
      " " => nil,
    }.each do |time, expected_result|
      it "is #{expected_result.inspect} for #{time.try(:ago).inspect}" do
        expect(helper.recent_distance_in_words(time.try(:ago))).to be == expected_result
      end
    end
  end

  describe "#global_stats" do
    it "returns a GlobalStats instance" do
      expect(helper.global_stats).to be_a GlobalStats
    end

    it "memoizes the instance" do
      expect(helper.global_stats.object_id).to be == helper.global_stats.object_id
    end
  end

  describe "#rank" do
    it "renders an icon for the given rank" do
      expected = "<i class=\"fa fa-caret-up rank rank-2\" title=\"Upper half of all projects\"></i>"
      expect(helper.rank(metric: :rubygem_downloads, value: 5000)).to be == expected
    end
  end

  describe "#rank_icon" do
    it "is 'fa-angle-double-up' when rank is 5" do
      expect(helper.rank_icon(5)).to be == "fa-angle-double-up"
    end

    it "is 'fa-caret-up' when rank is below 5" do
      expect(helper.rank_icon(rand(5))).to be == "fa-caret-up"
    end
  end

  describe "#rank_tooltip" do
    {
      nil => nil,
      "" => nil,
      1 => "Lower half of all projects",
      2 => "Upper half of all projects",
      3 => "Upper quarter of all projects",
      4 => "Top 5% of all projects",
      5 => "Top 1% of all projects",
    }.each do |rank, expected_label|
      it "returns #{expected_label.inspect} for rank #{rank}" do
        expect(helper.rank_tooltip(rank)).to be == expected_label
      end
    end
  end
end
