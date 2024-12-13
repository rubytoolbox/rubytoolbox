# frozen_string_literal: true

class ErrorPageGenerator
  def self.write_all!
    I18n.t(:error_pages).each_key do |key|
      new(key).write!
    end
  end

  private attr_accessor :title, :subtitle, :path

  public :title, :subtitle

  def initialize(key)
    self.path = Rails.public_path.join("#{key}.html")
    self.title = I18n.t :title, scope: "error_pages.#{key}", raise: true
    self.subtitle = I18n.t :subtitle, scope: "error_pages.#{key}", raise: true
  end

  def write!
    path.open("w+") { _1.puts rendered }
  end

  def rendered
    template.render(self)
  end

  private

  def template
    Tilt.new File.join(__dir__, "error_page.slim")
  end
end
