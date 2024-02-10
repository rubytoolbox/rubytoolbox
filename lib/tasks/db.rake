namespace :db do
  desc "Pull the latest Ruby Toolbox database dump and import it"
  task sync: :environment do
    db_sync = DatabaseSync.new
    db_sync.sync!
  end
end
