# frozen_string_literal: true

class RubygemDownloadStat < ApplicationRecord
  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :download_stats
end
