# frozen_string_literal: true

require "rails_helper"

RSpec.describe Database::StoreSelectiveExportJob do
  fixtures :all

  let(:job) { described_class.new }

  describe ".outdated_exports"

  describe "#perform" do
    subject(:perform) { job.perform }

    let(:export_file) { Tempfile.create("export-test") }

    before do
      allow(Database::SelectiveExport).to receive(:call).and_yield export_file
      File.open(export_file.path, "w+") { _1.puts SecureRandom.hex(128) }
    end

    it "creates a new export" do
      expect { perform }.to change(Database::Export, :count).by(1)
    end

    it { is_expected.to be_a Database::Export }

    it "attaches the export file" do
      file = perform.file

      expect(file).to have_attributes(
        download: File.read(export_file),
        filename: ActiveStorage::Filename.new(File.basename(export_file))
      )
    end

    it "expires outdated exports" do
      outdated = instance_double Database::Export.all.class
      allow(Database::Export).to receive(:outdated).and_return outdated

      expect(outdated).to receive(:destroy_all)
      perform
    end
  end
end
