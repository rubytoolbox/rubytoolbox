# frozen_string_literal: true

class Docs
  class Page
    attr_accessor :id
    private :id=

    def initialize(id)
      self.id = id
    end

    def title
      I18n.t File.basename(id), scope: "docs.titles"
    end

    def section
      @section ||= Pathname.new(id).dirname.basename.to_s
    end

    def active?(other_id)
      id == other_id
    end

    alias to_param id
  end

  def find(id)
    pages.find { |page| page.id == id }
  end

  def sections
    @sections ||= {
      "Guides"   => pages_in(:guides),
      "Features" => pages_in(:features),
      "API"      => pages_in(:api),
      "Metrics"  => pages_in(:metrics),
    }
  end

  private

  def pages
    @pages ||= HighVoltage.page_ids
                          .select { |page_id| page_id.start_with? "docs" }
                          .sort
                          .map { |page_id| Page.new(page_id) }
  end

  def pages_in(subpath)
    pages.select { |page| page.section == subpath.to_s }
  end
end
