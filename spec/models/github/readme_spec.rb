# frozen_string_literal: true

require "rails_helper"

RSpec.describe Github::Readme, type: :model do
  fixtures :all

  let(:repo) do
    GithubRepo.new(
      path:           "foo/bar",
      default_branch: "main"
    )
  end

  let(:model) do
    described_class.new(
      html:        "<p>Hello World</p>",
      etag:        "123123",
      github_repo: repo
    )
  end

  describe "html=" do
    it "passes the input through the scrubber" do
      base_url = "https://example.com/foo"
      allow(model.github_repo).to receive(:blob_url).and_return(base_url)
      allow(Github::Readme::Scrubber).to receive(:scrub)
        .with("input html", base_url:)
        .and_return("scrubbed")

      model.html = "input html"

      expect(model.html).to be == "scrubbed"
    end
  end

  describe "#truncated_html" do
    it "is nil when html is empty" do
      model.html = " "
      expect(model.truncated_html).to be nil
    end

    it "returns truncated html" do
      model.html = '<a href="https://example.com">Hello</a><p>More</p>'
      expect(model.truncated_html(limit: 40)).to be == "<a href='https://example.com'>Hello</a><p>...</p>"
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
