# frozen_string_literal: true

#
# Storage vehicle for database exports done with Database::SelectiveExport
#
class Database::Export < ApplicationRecord
  has_one_attached :file

  def self.latest
    order(created_at: :desc).first!
  end

  delegate :url, to: :file, prefix: true
end
