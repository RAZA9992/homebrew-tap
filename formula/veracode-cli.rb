class VeracodeCli < Formula
  desc "This is a homebrew formula for Veracode CLI"
  homepage "https://www.veracode.com"
  version "2.26.0"
  license "MIT"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.26.0_macosx_arm64.tar.gz"
      sha256 "d77b2aa19842b67f4b5a509300b6afbe7c8fbb934afbd932392b1fd457756fb2"
    elsif Hardware::CPU.intel?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.26.0_macosx_x86.tar.gz"
      sha256 "68bdf646faeebe0a97e41e83d65c00b7812b87a54b62b3aae865a3b5ca768c0b"
    end
  elsif OS.linux?
    url "https://tools.veracode.com/veracode-cli/veracode-cli_2.26.0_linux_x86.tar.gz"
    sha256 "96d76c6cac0d8f4d216131f0a51882f421e1c018a70a189d333dcb1b35638810"
  end
  def install
    bin.install "veracode"
  end
  test do
    system "#{bin}/veracode", "version"
  end
end
