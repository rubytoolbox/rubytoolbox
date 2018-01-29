# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlogController, type: :controller do
  let(:posts) { described_class::BLOG.posts }

  describe "GET index" do
    let(:do_request) { get :index }

    it "responds with success" do
      expect(do_request).to have_http_status :success
    end

    it "renders template index" do
      expect(do_request).to render_template :index
    end

    it "assigns posts" do
      do_request
      expect(assigns(:posts)).to be == posts
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
        expect(do_request).to have_http_status :success
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
