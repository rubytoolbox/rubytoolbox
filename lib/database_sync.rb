# frozen_string_literal: true

require "open-uri"
require "ruby-progressbar"
# require_relative "progress_io"

class DatabaseSync
  include ActionView::Helpers::NumberHelper

  BACKUP_PATH = Rails.root.join("tmp")
  DUMP_API_URL = "https://data.ruby-toolbox.com/backups.json"

  attr_reader :latest_backup_metadata

  def sync!
    fetch_latest_backup_metadata
    pull_latest_dump if should_pull_latest_dump?
    restore_dump
  end

  private

  def yes?(prompt)
    print "#{prompt} [y/N]: "
    response = $stdin.gets.chomp.downcase
    response == "y"
  end

  def fetch_latest_backup_metadata
    payload = URI.parse(DUMP_API_URL).open
    available_backups = Oj.load payload
    @latest_backup_metadata = available_backups.first.symbolize_keys
  end

  def target_dump_filename
    @latest_dump_filename ||=
      begin
        ts = DateTime.parse(latest_backup_metadata[:created_at]).strftime("%Y-%m-%d")
        "rubytoolbox_#{ts}.dump"
      end
  end

  def dump_destination
    File.join(BACKUP_PATH, target_dump_filename)
  end

  def latest_dump_exists?
    File.exist? dump_destination
  end

  def should_pull_latest_dump?
    return true unless latest_dump_exists?

    puts "It seems you already have the latest dump at #{dump_destination}"
    yes?("Do you want to re-download it?")
  end

  def delete_existing_dump_if_exists
    if File.exist?(dump_destination)
      puts "Removing existing dump at #{dump_destination}"
      File.delete(dump_destination)
    end
  end

  def pull_latest_dump
    puts "Most recent database dump available is from #{latest_backup_metadata[:created_at]}"

    delete_existing_dump_if_exists

    progress_bar = nil
    # progress_bar_format = "%a %e %P% (%c / %C)"
    # progress_bar_format = "%a |%b>>%i| %p%% "
    progress_bar_format = "%a %B %p%% %r KB/sec"
    uri = URI.parse(latest_backup_metadata[:download_url])
    uri.open(
      content_length_proc: ->(total_bytes) {
        if total_bytes&.positive?
          progress_bar = ProgressBar.create(
            total:      total_bytes,
            format:     "%a %B %p%% | %r KB/sec",
            rate_scale: ->(rate) { rate / 1024 }
          )
        end
      },
      progress_proc:       ->(downloaded_bytes) {
        progress_bar.progress = downloaded_bytes if progress_bar
      }
    ) do |f|
      IO.copy_stream(f, dump_destination)
    end

    download_file_size = File.size(dump_destination)
    formatted_file_size = number_to_human_size(download_file_size)
    puts "Dump downloaded successfully (#{formatted_file_size})"
  end

  def restore_dump
    unless File.size?(dump_destination) == latest_backup_metadata[:size]
      puts "Downloaded dump size does not match expected size, aborting"
      return
    end

    db_config = ApplicationRecord.configurations.find_db_config(Rails.env).configuration_hash
    puts "\n== Running pg_restore against #{db_config[:database]} =="

    puts "DB CONFIG: #{db_config.inspect}"

    restore_cmd = <<~CMD.squish
      pg_restore --clean --no-acl --create --no-owner
                 -h #{db_config[:host]}
                 -p #{db_config[:port]}
                 -U #{db_config[:username]}
                 -d #{Shellwords.escape(db_config[:database])}
                 --verbose
                 #{Shellwords.escape(dump_destination)}
    CMD

    puts "Running: #{restore_cmd}"
    result = system restore_cmd

    if result
      sync_migration_version
      puts "Database successfully imported! There are now #{number_with_precision(Rubygem.count)} gems in the database."
    else
      puts "Database import failed :("
    end
  end

  def sync_migration_version
    latest_version_sql = "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
    result = ActiveRecord::Base.connection.execute(latest_version_sql)
    latest_migration_version = result.count > 0 ? result.first["version"].to_i : 0

    versions = Dir[Rails.root.join("db/migrate/*.rb")].map do |file|
      File.basename(file).split("_").first.to_i
    end

    return if latest_migration_version >= versions.last

    ActiveRecord::Base.connection.execute("DELETE FROM schema_migrations")
    sql = "INSERT INTO \"schema_migrations\" (version) VALUES "
    sql += versions.map { |version| "('#{version}')" }.join(", ")
    ActiveRecord::Base.connection.execute(sql)
  end
end
