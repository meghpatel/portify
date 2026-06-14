# This file belongs in your TAP repo (homebrew-tap), at: Formula/portify.rb
# After `brew tap meghpatel/tap`, users run `brew install portify`.
#
# To update for a new release:
#   1. bump `url` to the new version tag
#   2. replace `sha256` with the value printed by release.sh
class Portify < Formula
  desc "Port registry lookup, allocation, and scanning CLI"
  homepage "https://github.com/meghpatel/portify"
  url "https://github.com/meghpatel/portify/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "e917f5a471887c67bb39e162a0edf56f6918f746e92b0406409688f1e609e3cb"
  license "MIT"
  version "1.0.1"

  def install
    bin.install "portify"
  end

  test do
    assert_match "portify 1.0.0", shell_output("#{bin}/portify --version")
    assert_match "Usage", shell_output("#{bin}/portify --help")
  end
end
