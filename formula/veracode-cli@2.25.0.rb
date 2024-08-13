class VeracodeCli < Formula
  desc "This is a homebrew formula for Veracode CLI"
  homepage "https://www.veracode.com"
  version "2.25.0"
  license "MIT"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.25.0_macosx_arm64.tar.gz"
      sha256 "1102f6032dcf912e3f5ed680c9d07e54c7a971fca19b430adf8bd7be486506fd"
    elsif Hardware::CPU.intel?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.25.0_macosx_x86.tar.gz"
      sha256 "c473b7e4c9884a16f8688f30440925853ba403bba3b309447b3b62e438f5a6d3"
    end
  elsif OS.linux?
    url "https://tools.veracode.com/veracode-cli/veracode-cli_2.25.0_linux_x86.tar.gz"
    sha256 "f86feeef21c0d494b5544f994ab2c906b46ca053267e0d3b1d04545da1936e62"
  end
  def install
    bin.install "veracode"
  end
  test do
    system "#{bin}/veracode", "version"
  end
end