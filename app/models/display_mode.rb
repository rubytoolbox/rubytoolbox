# frozen_string_literal: true

#
# A little utility class for picking a display mode based on given param,
# falling back to a customizible default
#
class DisplayMode
  attr_accessor :requested, :default, :available
  private :requested=, :default=, :available=

  def initialize(requested = nil, default: "full")
    self.requested = requested.to_s
    self.default = default.to_s
    self.available = %w[full compact table]
  end

  def current
    return requested if available.include? requested

    available.find { |mode| mode == default } || available.first
  end
end
