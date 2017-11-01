# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  describe "GET show" do
    describe "for unknown category" do
      let(:do_request) { get :show, params: { id: "foobar" } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { do_request }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "for known category" do
      let(:do_request) { get :show, params: { id: category.permalink } }

      let(:category) do
        Category.create! permalink: "category",
                         name: "Category",
                         category_group: CategoryGroup.create!(name: "Group", permalink: "group")
      end

      it "responds with success" do
        expect(do_request).to have_http_status :success
      end

      it "renders template show" do
        expect(do_request).to render_template :show
      end

      it "assigns Category.find_for_show!" do
        allow(Category).to receive(:find_for_show!).and_return("The Category")
        do_request
        expect(assigns(:category)).to be == "The Category"
      end
    end
  end
end
