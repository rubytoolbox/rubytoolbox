# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectsController, type: :controller do
  describe "GET show" do
    describe "for unknown project" do
      let(:do_request) { get :show, params: { id: "foobar" } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { do_request }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "for known project" do
      let(:do_request) { get :show, params: { id: project.permalink } }

      let(:project) do
        Project.create! permalink: "category"
      end

      it "responds with success" do
        expect(do_request).to have_http_status :success
      end

      it "renders template show" do
        expect(do_request).to render_template :show
      end

      it "assigns Project.find_for_show!" do
        allow(Project).to receive(:find_for_show!).and_return(project)
        do_request
        expect(assigns(:project)).to be == project
      end
    end
  end
end
