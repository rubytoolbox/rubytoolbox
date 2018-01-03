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
end
