# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemDownloadStat, type: :model do
  it "has a unique index on rubygem name and date" do
    rubygem = Factories.rubygem "example"
    do_create = lambda {
      rubygem.download_stats.create! total_downloads: 2000, date: Time.zone.today
    }

    do_create.call

    expect(&do_create).to raise_error(ActiveRecord::RecordNotUnique)
  end
end
