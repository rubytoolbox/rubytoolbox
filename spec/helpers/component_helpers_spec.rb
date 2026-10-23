# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComponentHelpers do
  fixtures :all

  let(:group) do
    CategoryGroup.create! permalink: "unimportant", name: "unimportant"
  end
  let(:category) do
    Category.create! permalink:      "mocking",
                     name:           "Mocking Frameworks",
                     description:    "Widgets Factory",
                     category_group: group
  end

  describe "#release_history_start_year" do
    let(:this_year) { Time.current.year }

    it "starts with the year of the first recorded release" do
      expect(helper.release_history_start_year({ "2016-2" => 1, "2012-4" => 3, "2019-1" => 12 })).to eq 2012
    end

    it "starts with the current year when there is no usable release data" do
      expect(helper.release_history_start_year({})).to eq this_year
    end

    it "does not reach back further than the compact limit for old projects" do
      expect(helper.release_history_start_year({ "2008-1" => 1 }, compact: true)).to eq this_year - 5
    end

    it "starts with the first release year in compact view for young projects" do
      key = "#{this_year - 2}-1"
      expect(helper.release_history_start_year({ key => 1 }, compact: true)).to eq this_year - 2
    end
  end

  describe "#project_release_history" do
    it "renders no years before the first release" do
      html = helper.project_release_history({ "2018-3" => 1, "2019-1" => 12 })
      expect(Capybara.string(html).all(".year .label").map(&:text)).to start_with("2018")
    end

    it "renders nothing without release counts" do
      expect(helper.project_release_history({})).to be_nil
    end
  end

  describe "#category_card" do
    before do
      Factories.project("sample").update! categories: [category]
    end

    it "issues no count db queries" do
      category = Category.includes(:projects).find("mocking")

      expect { helper.category_card(category) }.not_to make_database_queries
    end
  end
end
