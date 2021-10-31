# frozen_string_literal: true

#
# This is a tiny wrapper for running pre-built tokei binaries bundled
# with this repo against the host operating system, to ease local development
# as well as CI and deployment target setup.
#
# Tokei produces lines of code statistics for a given file system tree.
#
# More on tokei: https://github.com/XAMPPRocky/tokei
#
class Tokei
  BIN_BASE_PATH = Pathname.new(__dir__).expand_path.join("bin")

  UnknownPlatformError = Class.new StandardError

  Platform = Struct.new(:arch, :executable, :sha256sum) do
    # Path of pre-built tokei binary suitable for current platform
    def path
      BIN_BASE_PATH.join(executable)
    end

    # Checks actual sha256 checksum against pre-defined one
    def checksum_valid?
      Digest::SHA256.file(path).hexdigest == sha256sum
    end
  end
  PLATFORMS = [
    Platform.new("x86_64-linux", "tokei-v12.1.2-x86_64-linux",
                 "886955aa9b634a75164255169311dd316f742774f8d76aede13d1e3ce83e9830"),
  ].freeze

  private attr_accessor :platform

  def initialize(arch = RbConfig::CONFIG["arch"])
    match = PLATFORMS.find { _1.arch == arch }
    raise UnknownPlatformError unless match

    self.platform = match
  end

  delegate :path, :checksum_valid?, to: :platform
end
