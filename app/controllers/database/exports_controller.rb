# frozen_string_literal: true

#
# This controller gives access to (selective) database exports
# by redirecting to their file storage URL
#
class Database::ExportsController < ApplicationController
  def selective
    # latest will raise active record not found when not available,
    # whill will be treated by standard 404 handling
    redirect_to Database::Export.latest.file_url, allow_other_host: true
  end
end
