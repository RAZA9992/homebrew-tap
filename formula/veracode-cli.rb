class VeracodeCli < Formula
  desc "You use the Veracode CLI to perform various actions for testing the security of your applications."
  homepage "https://www.veracode.com"
  version "VERSION_PLACEHOLDER"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_macosx_arm64.tar.gz"
      sha256 "SHA256_MACOS_ARM64_PLACEHOLDER"
    elsif Hardware::CPU.intel?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_macosx_x86.tar.gz"
      sha256 "SHA256_MACOS_X86_PLACEHOLDER"
    end

    def install
      bin.install "veracode"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_VERSION_PLACEHOLDER_linux_x86.tar.gz"
      sha256 "SHA256_LINUX_X86_PLACEHOLDER"
    end

    def install
      bin.install "veracode"
    end
  end

  test do
    system "#{bin}/veracode", "version"
  end
end
