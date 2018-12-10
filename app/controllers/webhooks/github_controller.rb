# frozen_string_literal: true

class Webhooks::GithubController < ApplicationController
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  def github_status(payload)
    return unless build_deployed? payload

    CatalogImportJob.perform_async
  end

  private

  #
  # The catalog JSON export is built on CI and then deployed manually to
  # github pages, which does not seem to trigger a `page_build` notification
  # event webhook from github. Therefore, we watch for the successful CI
  # status on the default branch instead.
  #
  def build_deployed?(payload)
    payload.dig("state") == "success" && payload.dig("branches", "name") == payload.dig("repository", "default_branch")
  end

  def webhook_secret(_payload)
    ENV.fetch "GITHUB_WEBHOOK_SECRET"
  end
end
