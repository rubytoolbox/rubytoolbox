# frozen_string_literal: true

require "rails_helper"

RSpec.describe Github::Readme, type: :model do
  let(:model) do
    described_class.new(
      html: "<p>Hello World</p>",
      etag: "123123"
    )
  end

  describe "#sanitized_html" do
    it "is nil when html is empty" do
      model.html = " "
      expect(model.sanitized_html).to be nil
    end

    it "cleans weird html content" do
      model.html = %q{<a href="/" onclick="alert('lol');">Hello</a>}
      expect(model.sanitized_html).to be == '<a href="/">Hello</a>'
    end

    it "returns html_safe string" do
      model.html = "<em>Foo</em>"
      expect(model.sanitized_html).to be_html_safe
    end
  end

  describe "#truncated_html" do
    it "is nil when html is empty" do
      model.html = " "
      expect(model.truncated_html).to be nil
    end

    it "returns sanitized, truncated html" do
      model.html = %q{<a href="/" onclick="alert('lol');">Hello</a><p>More</p>}
      expect(model.truncated_html(limit: 20)).to be == "<a href='/'>Hello</a>..."
    end

    it "returns html_safe string" do
      model.html = "<em>Foo</em>"
      expect(model.truncated_html).to be_html_safe
    end
  end
end
