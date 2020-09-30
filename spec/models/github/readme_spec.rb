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

  describe Github::Readme::Scrubber do
    describe ".scrub" do
      it "returns nil if html is blank" do
        expect(described_class.scrub(" \n ")).to be nil
      end

      it "cleans weird html content" do
        html = %q{<a href="/" onclick="alert('lol');">Hello</a>}
        expect(described_class.scrub(html)).to be == '<a href="/">Hello</a>'
      end

      it "removes links to named anchors" do
        html = '<p><a href="#foobar">Hello</a></p>'
        expect(described_class.scrub(html)).to be == "<p>Hello</p>"
      end

      # rubocop:disable RSpec/ExampleLength
      it "exchanges relative links with base url when given" do
        html = <<~HTML
          <p><a href="https://example.com">Unchanged</a></p>
          <p><a href="foo/relative">Changed</a></p>
          <p><a href="/absolute">Changed too</a></p>
        HTML

        expected = <<~HTML
          <p><a href="https://example.com">Unchanged</a></p>
          <p><a href="https://example.com/subpath/foo/relative">Changed</a></p>
          <p><a href="https://example.com/absolute">Changed too</a></p>
        HTML

        expect(described_class.scrub(html, base_url: "https://example.com/subpath")).to be == expected
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
