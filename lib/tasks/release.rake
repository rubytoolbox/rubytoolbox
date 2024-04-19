# frozen_string_literal: true

desc "Tasks to run after each deployment"
task release: :environment do
  puts "=== Running additional post-release tasks ==="
  puts "-> Queueing Database::StoreSelectiveExportJob"
  Database::StoreSelectiveExportJob.perform_async
end
