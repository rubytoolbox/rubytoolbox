# frozen_string_literal: true

#
# Creates a Database::SelectiveExport and saves it as a Database::Export
#
class Database::StoreSelectiveExportJob < ApplicationJob
  def perform
    Database::SelectiveExport.call do |export_file|
      Database::Export.transaction do
        Database::Export.new.tap do |export_record|
          export_record.file.attach export_file
          export_record.save!
        end
      end
    end
  end
end
