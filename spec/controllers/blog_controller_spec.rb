# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlogController, type: :controller do
  render_views

  let(:posts) { described_class::BLOG.posts }

  describe "GET index" do
    shared_examples_for "a blog index response" do
      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "renders template index" do
        expect(do_request).to render_template :index
      end

      it "assigns posts" do
        do_request
        expect(assigns(:posts)).to be == posts
      end
    end

    describe "default format" do
      let(:do_request) { get :index }

      it_behaves_like "a blog index response"
    end

    describe "rss format" do
      let(:do_request) { get :index, format: :rss }

      it_behaves_like "a blog index response"

      describe "rendered feed" do
        let(:feed) { Feedjira.parse do_request.body }

        it "has the site title" do
          expect(feed.title).to be == I18n.t(:name)
        end

        it "has the site description" do
          expect(feed.description).to be == I18n.t(:description)
        end

        it "has the post titles" do
          expect(feed.entries.map(&:title)).to be == posts.map(&:title)
        end

        it "has the post bodies" do
          expect(feed.entries.map(&:summary)).to be == posts.map(&:body_html)
        end

        it "has the post publication dates" do
          expect(feed.entries.map(&:published)).to be == posts.map(&:published_on)
        end

        it "has correct post urls" do
          expected_urls = posts.map { |post| File.join request.base_url, "blog", post.slug }
          expect(feed.entries.map(&:url)).to be == expected_urls
        end
      end
    end
  end

  describe "GET show" do
    describe "for unknown post" do
      let(:do_request) { get :show, params: { id: "foobar" } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { do_request }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "for known post" do
      let(:do_request) { get :show, params: { id: post.slug } }

      let(:post) do
        posts.first
      end

      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "renders template show" do
        expect(do_request).to render_template :show
      end

      it "assigns expected post" do
        do_request
        expect(assigns(:post)).to be == post
      end
    end
  end
end
