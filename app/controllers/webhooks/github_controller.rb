# frozen_string_literal: true

class Webhooks::GithubController < ApplicationController
  class SignatureError < StandardError; end
  class UnsupportedEventError < StandardError; end

  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  def github_page_build(payload)
    return unless build_deployed? payload

    CatalogImportJob.perform_in 30.seconds
  end

  private

  #
  # The catalog JSON export is built on CI and then deployed manually to
  # github pages, which does not seem to trigger a `page_build` notification
  # event webhook from github. Therefore, we watch for the successful CI
  # status on the default branch instead.
  #
  def build_deployed?(payload)
    default_branch = payload.dig("repository", "default_branch")
    referenced_branches = payload["branches"]&.pluck("name")
    payload["state"] == "success" && referenced_branches&.include?(default_branch)
  end

  # GithubWebhook::Processor raises generic AbstractController::ActionNotFound
  # for signature failures. We wrap it to raise a more descriptive error.
  def authenticate_github_request!
    super
  rescue AbstractController::ActionNotFound
    raise SignatureError
  end

  # GithubWebhook::Processor raises generic AbstractController::ActionNotFound
  # for unsupported events. We wrap it to raise a more descriptive error.
  def check_github_event!
    super
  rescue AbstractController::ActionNotFound
    raise UnsupportedEventError
  end

  def webhook_secret(_payload)
    ENV.fetch "GITHUB_WEBHOOK_SECRET"
  end
end
