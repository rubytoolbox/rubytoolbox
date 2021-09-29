# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryGroup, type: :model do
  fixtures :all

  describe ".for_welcome_page" do
    subject(:scope) { described_class.for_welcome_page.to_sql }

    it { is_expected.to be == described_class.order(name: :asc).includes(:categories).to_sql }
  end
end
