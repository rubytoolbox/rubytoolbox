# frozen_string_literal: true

class Webhooks::GithubController < ApplicationController
  include GithubWebhook::Processor

  def github_page_build(_payload)
    CatalogImportJob.perform_async
  end

  private

  def webhook_secret(_payload)
    ENV.fetch "GITHUB_WEBHOOK_SECRET"
  end
end
