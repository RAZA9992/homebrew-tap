class VeracodeCli < Formula
    desc "This is a homebrew formula for Veracode CLI"
    homepage "https://www.veracode.com"
    version "2.24.0"
    license "MIT"
    if OS.mac?
      if Hardware::CPU.arm?
        url "https://tools.veracode.com/veracode-cli/veracode-cli_2.24.0_macosx_arm64.tar.gz"
        sha256 "1cb2ec914a200e91f00f53aff94c80be6f8a5cfa98b98c943510e61538c0e492"
      elsif Hardware::CPU.intel?
        url "https://tools.veracode.com/veracode-cli/veracode-cli_2.24.0_macosx_x86.tar.gz"
        sha256 "304a3da77481f9deccbcff7ed5ac668a7a767b21630f7d9c13e3f31c4e31ccd0"
      end
    elsif OS.linux?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.24.0_linux_x86.tar.gz"
      sha256 "f850bad67f0c95a1f7db0d0f0c9800731c7eb86c0109efa4b8d14434afb20e37"
    end
    def install
      bin.install "veracode"
    end
    test do
      system "#{bin}/veracode", "version"
    end
  end