# frozen_string_literal: true

class Github::Readme < ApplicationRecord
  module Scrubber
    class << self
      #
      # Sanitizes given html, drops named anchors and adjusts relative
      # links to be based on given base_url (if passed, otherwise that step
      # is skipped)
      #
      def scrub(html, base_url: nil)
        return if html.blank?

        sanitized = Sanitize.fragment(html, Sanitize::Config::RELAXED)

        fix_links sanitized, base_url:
      end

      private

      def fix_links(sanitized, base_url:)
        doc = Nokogiri::HTML.fragment sanitized

        doc.css("a[href]").each do |a|
          adjust_link a, base_url:
        end

        doc.to_s
      end

      def adjust_link(link, base_url:)
        href = link["href"]

        # Scrub links to named anchors
        if href.start_with?("#")
          link.replace link.inner_html
        # Relative links get aligned to base_url, depending on whether
        # it's an absolute or relative path
        elsif base_url && href.exclude?("://")
          link["href"] = if href.start_with?("/")
                           URI.join base_url, href
                         else
                           File.join base_url, href
                         end
        end
      end
    end
  end

  self.primary_key = :path
  self.table_name = :github_readmes

  belongs_to :github_repo,
             primary_key: :path,
             foreign_key: :path,
             inverse_of:  :readme

  def html=(html)
    super(Scrubber.scrub(html, base_url: github_repo&.blob_url))
  end

  def truncated_html(limit: 2000)
    return if html.blank?

    Truncato.truncate(html, max_length: limit)
  end
end
