# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper do
  fixtures :all

  describe "#expiring_cache" do
    it "builds a cache key based on given label, time, and release version" do
      allow(ENV).to receive(:fetch).with("HEROKU_RELEASE_VERSION", nil).and_return("v42")
      timestamp = Time.current.to_i / 10.minutes

      expect(helper).to receive(:cache).with("test-v42-#{timestamp}")

      helper.expiring_cache :test
    end
  end

  describe "#metrics_row" do
    let(:project) { instance_double(Project, rubygem_downloads: 22_123_122) }
    let(:metrics_row) { helper.metrics_row(project, :rubygem_downloads) }

    it "renders the expected label" do
      expect(metrics_row).to include("<span>Downloads</span>")
    end

    it "renders the given icon" do
      expect(metrics_row).to include("<i class=\"fa fa-download\"></i>")
    end

    it "renders integers pretty-printed" do
      expect(metrics_row).to include("22,123,122")
    end

    it "renders floats floored and pretty-printed as a percentage" do
      allow(project).to receive(:rubygem_downloads).and_return(1297.7)
      expect(metrics_row).to include("1,297%")
    end

    it "renders dates regularly" do
      allow(project).to receive(:rubygem_downloads).and_return(Date.new(2014, 7, 4))
      expect(metrics_row).to include("2014-07-04")
    end

    it "renders times as dates" do
      allow(project).to receive(:rubygem_downloads).and_return(Time.utc(2014, 7, 4, 13, 13, 0))
      expect(metrics_row).to include("2014-07-04")
    end

    it "renders strings as-is" do
      allow(project).to receive(:rubygem_downloads).and_return("Hello")
      expect(metrics_row).to include "Hello"
    end

    it "renders arrays as sentences" do
      allow(project).to receive(:rubygem_downloads).and_return(%w[Hello World])
      expect(metrics_row).to include "Hello and World"
    end

    it "renders only the container when the value is blank" do
      allow(project).to receive(:rubygem_downloads)
      expect(metrics_row).to eq "<div class=\"metric\" data-metric-name=\"rubygem_downloads\"></div>"
    end
  end

  describe "#link_to_docs_if_exists" do
    it "is a link when given a valid docs page path" do
      link = helper.link_to_docs_if_exists("docs/features/bugfix_forks") { "foo" }
      expect(link).to eq '<a href="/pages/docs/features/bugfix_forks">foo</a>'
    end

    it "is just the content of the block when not given a valid docs path" do
      link = helper.link_to_docs_if_exists("foo") { "foo" }
      expect(link).to eq "foo"
    end
  end

  describe "#title" do
    it "is the site name and tagline by default" do
      expect(helper.title).to eq [helper.site_name, helper.tagline].join(" - ")
    end

    it "uses the content_for title if present and appends site name" do
      helper.content_for(:title) { "My content" }
      expect(helper.title).to eq ["My content", helper.site_name].join(" - ")
    end

    it "returns default title even when given when default: true" do
      helper.content_for(:title) { "My content" }
      expect(helper.title(default: true)).to eq [helper.site_name, helper.tagline].join(" - ")
    end
  end

  describe "#description" do
    it "comes from i18n by default" do
      expect(helper.description).to eq I18n.t(:description)
    end

    it "can be customized using content_for" do
      helper.content_for(:description) { "Some other text" }
      expect(helper.description).to eq "Some other text"
    end
  end

  describe "#active_when" do
    before do
      allow(helper).to receive(:controller_name).and_return("test")
    end

    it "is 'is-active' when given controller matches current controller name" do
      expect(helper.active_when(controller: "test")).to eq "is-active"
    end

    it "is 'is-active' when matching controller is given as symbol" do
      expect(helper.active_when(controller: :test)).to eq "is-active"
    end

    it "is nil when given controller name does not match current controller name" do
      expect(helper.active_when(controller: "foo")).to be_nil
    end
  end
end
