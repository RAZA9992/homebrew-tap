class VeracodeCli < Formula
  desc "Command-line tool for testing application security with Veracode"
  homepage "https://www.veracode.com"
  version "VERSION_PLACEHOLDER"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_macosx_arm64.tar.gz"
      sha256 "SHA256_MACOS_ARM64_PLACEHOLDER"
    elsif Hardware::CPU.intel?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_macosx_x86.tar.gz"
      sha256 "SHA256_MACOS_X86_PLACEHOLDER"
    end
  elsif OS.linux?
    url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_linux_x86.tar.gz"
    sha256 "SHA256_LINUX_X86_PLACEHOLDER"
  end

  def install
    bin.install "veracode"
  end

  test do
    system "#{bin}/veracode", "version"
  end
end
