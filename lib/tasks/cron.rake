# frozen_string_literal: true

desc "Cron task to trigger recurring stuff based on the time. Expected to be invoked hourly."
task cron: :environment do
  Cron.new.run
end
