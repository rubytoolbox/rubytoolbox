# frozen_string_literal: true

class CatalogImportJob < ApplicationJob
  def perform
    response = http_client.get catalog_url
    raise "Failed to fetch catalog, response status was #{response.status}" unless response.status == 200
    catalog_data = JSON.parse response.body
    CatalogImport.perform(catalog_data)
  end

  def catalog_url
    "https://rubytoolbox.github.io/catalog/catalog.json"
  end

  def http_client
    @http_client ||= HttpService.client
  end
end
