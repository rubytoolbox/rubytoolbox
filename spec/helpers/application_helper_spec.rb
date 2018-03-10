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

  describe "#category_description" do
    it "returns a default for a Category without description" do
      category = Category.new name: "Indescribable Category"
      expect(helper.category_description(category)).to be == "No description yet"
    end

    it "returns a given description of a Category" do
      category = Category.new name: "Described Category", description: "Some description"
      expect(helper.category_description(category)).to be == "Some description"
    end
  end
end
