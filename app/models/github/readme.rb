# frozen_string_literal: true

class Github::Readme < ApplicationRecord
  self.primary_key = :path
  self.table_name = :github_readmes

  belongs_to :github_repo,
             primary_key: :path,
             foreign_key: :path,
             inverse_of:  :readme

  def sanitized_html
    return if html.blank?

    Sanitize.fragment(html, Sanitize::Config::RELAXED).html_safe # rubocop:disable Rails/OutputSafety
  end

  def truncated_html(limit: 2000)
    return if html.blank?

    Truncato.truncate(sanitized_html, max_length: limit).html_safe # rubocop:disable Rails/OutputSafety
  end
end
