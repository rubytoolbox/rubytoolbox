# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  fixtures :all

  describe "GET index" do
    let(:do_request) { get :index }

    it "responds with success" do
      expect(do_request).to be_successful
    end

    it "renders template index" do
      expect(do_request).to render_template :index
    end

    it "assigns CategoryGroup.for_welcome_page" do
      allow(CategoryGroup).to receive(:for_welcome_page).and_return("The Groups")
      do_request
      expect(assigns(:groups)).to be == "The Groups"
    end
  end

  describe "GET show" do
    describe "for unknown category" do
      let(:do_request) { get :show, params: { id: "foobar" } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { do_request }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "for known category" do
      def do_request(display: nil)
        get :show, params: { id: category.permalink, display: }
      end

      let(:category) do
        Category.create! permalink:      "category",
                         name:           "Category",
                         category_group: CategoryGroup.create!(name: "Group", permalink: "group")
      end

      it "responds with success" do
        expect(do_request).to be_successful
      end

      it "renders template show" do
        expect(do_request).to render_template :show
      end

      it "assigns Category.find_for_show!" do
        allow(Category).to receive(:find_for_show!).and_return(category)
        do_request
        expect(assigns(:category)).to be == category
      end

      it "passes a project order instance to Category.find_for_show!" do
        order = Project::Order.new(order: "rubygem_downloads")
        allow(Project::Order).to receive(:new).with(order: "rubygem_downloads").and_return(order)
        expect(Category).to receive(:find_for_show!).with(category.id, order:).and_return(Category.first)
        get :show, params: { id: category.id, order: "rubygem_downloads" }
      end

      describe "case-sensitivity" do
        ["CATegory", " catEGory "].each do |variant|
          it "redirects to the correct variant if accessed via #{variant.inspect}" do
            category
            expect(get(:show, params: { id: variant })).to redirect_to(category_url("category"))
          end
        end
      end

      it_behaves_like "pickable project display listing", "full"
    end
  end
end
