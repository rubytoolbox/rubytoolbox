# frozen_string_literal: true

module Github
  ALLOWED_HOSTS = %w[github.com www.github.com].freeze

  # Tries to find a github repo name from the given urls
  def self.detect_repo_name(*urls)
    urls.map(&:presence).compact.each do |url|
      next unless ALLOWED_HOSTS.include? URI.parse(url).host
      match = url.match %r{github\.com\/([^\/]+\/[^\/]+)}
      return match[1] if match
    rescue URI::InvalidURIError
      next
    end

    nil
  end
end
