# frozen_string_literal: true

#
# This class downloads and extracts the gem file for a given
# gem name and version, runs it through Tokei code statistics
# and returns the results wrapped in the ResultSet for convenience
#
class RubygemCodeStatsService
  class ResultSet
    class Entry
      attr_accessor :language, :blanks, :code, :comments

      def initialize(language, stats)
        self.language = language.tr(" ", "_").underscore
        self.blanks = stats.fetch("blanks")
        self.code = stats.fetch("code")
        self.comments = stats.fetch("comments")
      end
    end

    private attr_accessor :results
    delegate :each, to: :results
    include Enumerable

    def initialize(tokei_json_output)
      self.results = tokei_json_output.except("Total").map do |language, stats|
        Entry.new language, stats
      end
    end
  end

  def self.statistics(name:, version:)
    new(name: name, version: version).statistics
  end

  delegate :logger, to: :Rails

  private attr_accessor :name, :version

  def initialize(name:, version:)
    self.name = name
    self.version = version
  end

  def statistics
    with_extracted_gem do |extracted_gem_path|
      ResultSet.new Tokei.new.stats(extracted_gem_path)
    end
  end

  def gem_download_url
    "https://rubygems.org/downloads/#{filename}"
  end

  private

  def with_extracted_gem
    Dir.mktmpdir do |path|
      compressed_gem_path = download_gem_into(path)
      yield extract_gem(compressed_gem_path)
    end
  end

  def filename
    "#{name}-#{version}.gem"
  end

  def download_gem_into(directory)
    destination_path = Pathname.new(directory).join filename
    logger.info "Downloading gem #{name} #{version} into #{destination_path}"

    download! gem_download_url, to: destination_path

    logger.info "Gem written into #{destination_path}"

    destination_path
  end

  def extract_gem(compressed_gem_path)
    tmppathname = Pathname.new(compressed_gem_path).dirname.join("extracted")
    logger.info "Extracting #{File.basename(compressed_gem_path)} to #{tmppathname}"
    Minitar.unpack compressed_gem_path.to_s, tmppathname

    data_source = tmppathname.join("data.tar.gz")
    data_destination = tmppathname.join("data")
    reader = Zlib::GzipReader.new File.open(data_source, "rb")

    Minitar.unpack reader, data_destination

    data_destination
  end

  def download!(source_url, to:)
    response = HTTP.get source_url
    raise "Unknown response #{response.status}" unless response.status == 200

    Pathname.new(to).open "w+" do |f|
      f.print response.body.to_s
    end
  end
end
