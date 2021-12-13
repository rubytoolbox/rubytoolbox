# frozen_string_literal: true

#
# Persistence for lines of code statistics.
#
# See also RubygemCodeStatsService
#
class Rubygem::CodeStatistic < ApplicationRecord
  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :code_statistics
end
