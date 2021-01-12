# frozen_string_literal: true

require "rails_helper"

RSpec.describe Blog, type: :model do
  describe "with posts from fixtures" do
    let(:root) { Rails.root.join("spec", "fixtures", "blog_posts") }
    let(:blog) { described_class.new root: root }

    describe "#posts" do
      it "has 2 entries" do
        expect(blog.posts.length).to be == 2
      end

      it "is sorted by published_on DESC" do
        expect(blog.posts).to be == blog.posts.sort_by(&:published_on).reverse
      end

      it "has expected post published_on dates" do
        expect(blog.posts.map(&:published_on)).to be == [Date.new(2018, 1, 12), Date.new(2017, 12, 1)]
      end

      it "has expected post permalinks" do
        expect(blog.posts.map(&:permalink)).to be == %w[another-post example-post]
      end

      it "has expected post titles" do
        expect(blog.posts.map(&:title)).to be == ["Another title", "Example Title"]
      end

      it "has expected post html bodies" do
        expected_bodies = [
          "<p>Hello again!</p>",
          "<p>Hello World!</p><h1>Another h1, oops! Should end up in body, not title</h1>",
        ]
        expect(blog.posts.map(&:body_html)).to be == expected_bodies
      end
    end

    describe "#recent_posts" do
      it "contains posts published less than two months ago" do
        recent_post = instance_double described_class::Post, published_on: 1.month.ago.to_date
        old_post = instance_double described_class::Post, published_on: 3.months.ago.to_date
        allow(blog).to receive(:posts).and_return([recent_post, old_post])
        expect(blog.recent_posts).to be == [recent_post]
      end

      it "returns at most 3 recent posts" do
        post = instance_double described_class::Post, published_on: 1.month.ago.to_date
        allow(blog).to receive(:posts).and_return([post, post, post, post])
        expect(blog.recent_posts).to be == [post, post, post]
      end
    end

    describe ".find" do
      it "can find a given post by :published_on/:permalink" do
        expect(blog.find("2018-01-12/another-post")).to be == blog.posts.first
      end

      it "raises ActiveRecord::RecordNotFound when missing" do
        expect { blog.find("nothing") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "caching behaviour" do
      it "reloads posts every time by default" do
        loader = described_class::PostLoader.new(path: Dir[root.join("*.md")].first)
        expect(described_class::PostLoader).to receive(:new).exactly(4).times.and_return(loader)
        blog.posts
        blog.posts
      end

      it "does not reload posts in caching mode" do
        loader = described_class::PostLoader.new(path: Dir[root.join("*.md")].first)
        blog = described_class.new root: root, cache: true
        expect(described_class::PostLoader).to receive(:new).twice.and_return(loader)
        blog.posts
        blog.posts
      end
    end
  end
end
