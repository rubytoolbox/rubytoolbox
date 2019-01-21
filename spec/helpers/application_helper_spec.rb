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

    it "renders integers pretty-printed" do
      expect(project_metrics).to include("<strong>22,123,122</strong>")
    end

    it "renders floats floored and pretty-printed as a percentage" do
      allow(project).to receive(:rubygem_downloads).and_return(1297.7)
      expect(project_metrics).to include("<strong>1,297%</strong>")
    end

    it "renders dates pretty-printed" do
      allow(project).to receive(:rubygem_downloads).and_return(Date.new(2014, 7, 4))
      Timecop.travel Date.new(2015, 7, 4) do
        expect(project_metrics).to include("<time datetime=\"2014-07-04\" title=\"2014-07-04\">about 1 year ago</time>")
      end
    end

    it "renders times pretty-printed" do
      allow(project).to receive(:rubygem_downloads).and_return(Time.utc(2014, 7, 4, 13, 13, 0))
      Timecop.travel Date.new(2015, 7, 4) do
        expected = '<time datetime="2014-07-04T13:13:00Z" title="Fri, 04 Jul 2014 13:13:00 +0000">12 months ago</time>'
        expect(project_metrics).to include(expected)
      end
    end

    it "renders strings as-is" do
      allow(project).to receive(:rubygem_downloads).and_return("Hello")
      expect(project_metrics).to include "<strong>Hello</strong>"
    end

    it "renders arrays as sentences" do
      allow(project).to receive(:rubygem_downloads).and_return(%w[Hello World])
      expect(project_metrics).to include "<strong>Hello and World</strong>"
    end

    it "renders only the container when the value is blank" do
      allow(project).to receive(:rubygem_downloads)
      expect(project_metrics).to be == "<div class=\"metric\" data-metric-name=\"rubygem_downloads\"></div>"
    end
  end

  describe "#percentiles" do
    it "returns a hash of number distribution percentiles" do
      Factories.project "example"
      expect(helper.percentiles(:rubygems, :downloads)).to be_a(Hash)
        .and(satisfy { |h| h.keys == (0..100).to_a.map { |n| "#{n}%" } })
        .and(satisfy { |h| h.values.all? { |v| v.is_a? Numeric } })
    end
  end

  describe "#date_groups" do
    before do
      # Null values must not cause problems...
      Rubygem.create! name: "foo", downloads: 1, current_version: 1

      [2014, 2014, 2016, 2016, 2016].each_with_index do |year, i|
        Rubygem.create! name:             i,
                        downloads:        i,
                        current_version:  i,
                        first_release_on: Date.new(year)
      end
    end

    it "returns counts grouped by year in given column" do
      expect(helper.date_groups(:rubygems, :first_release_on)).to be == {
        2014 => 2,
        2016 => 3,
      }
    end
  end

  describe "#link_to_docs_if_exists" do
    it "is a link when given a valid docs page path" do
      link = helper.link_to_docs_if_exists("docs/features/bugfix_forks") { "foo" }
      expect(link).to be == '<a href="/pages/docs/features/bugfix_forks">foo</a>'
    end

    it "is just the content of the block when not given a valid docs path" do
      link = helper.link_to_docs_if_exists("foo") { "foo" }
      expect(link).to be == "foo"
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
