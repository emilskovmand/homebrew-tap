class Prbar < Formula
  desc "Menu bar app for your open GitHub PRs and the AI agents working on them"
  homepage "https://github.com/emilskovmand/prbar"
  url "https://github.com/emilskovmand/prbar/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "ed4db0773d735f14eee472ec0dee4b2246927c0ecb9c9434220762b85a8c2a7a"
  head "https://github.com/emilskovmand/prbar.git", branch: "main"

  depends_on macos: :sequoia
  depends_on "gh"

  def install
    # Built from source: a locally built, ad-hoc signed app isn't quarantined, so Gatekeeper lets it run.
    system "swift", "build", "--disable-sandbox", "-c", "release"

    app = prefix/"PRBar.app"
    (app/"Contents/MacOS").mkpath
    cp ".build/release/PRBar", app/"Contents/MacOS/PRBar"
    cp "Resources/Info.plist", app/"Contents/Info.plist"
    system "codesign", "--force", "--sign", "-", app

    # `prbar --dump` prints what the panel would show.
    bin.install_symlink app/"Contents/MacOS/PRBar" => "prbar"
  end

  service do
    run [opt_prefix/"PRBar.app/Contents/MacOS/PRBar"]
    keep_alive crashed: true
    process_type :interactive
  end

  def caveats
    <<~EOS
      Start PRBar now and at every login:
        brew services start prbar

      Or open it once without the service:
        open #{opt_prefix}/PRBar.app

      PRBar reads your open PRs with the GitHub CLI, so make sure it's logged in:
        gh auth login
    EOS
  end

  test do
    assert_predicate prefix/"PRBar.app/Contents/MacOS/PRBar", :executable?
  end
end
