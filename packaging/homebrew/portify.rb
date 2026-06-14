# This file belongs in your TAP repo (homebrew-tap), at: Formula/portify.rb
# After `brew tap meghpatel/tap`, users run `brew install portify`.
#
# To update for a new release:
#   1. bump `url` to the new version tag
#   2. replace `sha256` with the value printed by release.sh
class Portify < Formula
  desc "Port registry lookup, allocation, and scanning CLI"
  homepage "https://github.com/meghpatel/portify"
  url "https://github.com/meghpatel/portify/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "ce926ca30f41b87925c10c3f70e0577a2c2af34ec30d70238257e7e36661d285"
  license "MIT"
  version "1.1.0"

  def install
    bin.install "portify"
  end

  test do
    assert_match "portify 1.0.0", shell_output("#{bin}/portify --version")
    assert_match "Usage", shell_output("#{bin}/portify --help")
  end
end
