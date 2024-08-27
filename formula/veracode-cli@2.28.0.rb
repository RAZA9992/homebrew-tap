class VeracodeCli < Formula
    desc "This is a homebrew formula for Veracode CLI"
    homepage "https://www.veracode.com"
    version "2.26.0"
    license "MIT"
    if OS.mac?
      if Hardware::CPU.arm?
        url "https://tools.veracode.com/veracode-cli/veracode-cli_2.28.0_macosx_arm64.tar.gz"
        sha256 "cad9800ef4b592ea150b9b247f244340cd8b6433be68f5b54fc9c6d072f1454f"
      elsif Hardware::CPU.intel?
        url "https://tools.veracode.com/veracode-cli/veracode-cli_2.28.0_macosx_x86.tar.gz"
        sha256 "0557f9353e18f80f32e7e58d202e75efb7d6e0ec83325f8afa49321657216211"
      end
    elsif OS.linux?
      url "https://tools.veracode.com/veracode-cli/veracode-cli_2.28.0_linux_x86.tar.gz"
      sha256 "dd067965fc8b59f58f6e6aa98fbeda464274f5b9abeefb0f758c0090fd774dd3"
    end
    def install
      bin.install "veracode"
    end
    test do
      system "#{bin}/veracode", "version"
    end
  end