task brewInstall, "Install Homebrew (macOS only)":
  echo_section "Install Homebrew"

  if hostOS != "macosx":
    echo_skip "Not on macOS."
    return

  if gorgeEx("command -v brew").exitCode == 0:
    echo_skip "Homebrew is already installed."
    return

  discard safeExec("NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")

task brewCask, "Sync Homebrew Cask Application (macOS only)":
  echo_section "Install Applications with Homebrew"

  if hostOS != "macosx":
    echo_skip "Not on macOS."
    return

  if gorgeEx("command -v brew").exitCode != 0:
    echo_skip "Homebrew is not install."
    return

  let brewfile = dataDir / "Brewfile_cask"
  if not fileExists(brewfile):
    echo_error brewfile & " not found"
    return

  let res = safeExec("brew bundle --file=" & brewfile)
  if res.exitCode != 0:
    echo_error "Application install failed."
    return

  let packages = res.output.splitLines()
    .filterIt(it.contains("Using"))
    .mapIt(it.strip().split(' ')[1])
    .toHashSet()

  for package in packages:
    echo_info "Install: " & package

task brewMas, "Sync Homebrew App Store Apllication (macOS only)":
  echo_section "Install App Store Applications with Homebrew"

  if hostOS != "macosx":
    echo_skip "Not on macOS."
    return

  if gorgeEx("command -v brew").exitCode != 0:
    echo_skip "Homebrew is not install."
    return

  let brewfile = dataDir / "Brewfile_mas"
  if not fileExists(brewfile):
    echo_error brewfile & " not found"
    return

  let res = safeExec("brew bundle --file=" & brewfile)
  if res.exitCode != 0:
    echo_error "Application install failed."
    return

  let packages = res.output.splitLines()
    .filterIt(it.contains("Using"))
    .mapIt(it.strip().split(' ')[1])
    .toHashSet()

  for package in packages:
    echo_info "Install: " & package

task brew, "Sync Homebrew Bundle (macOS only)":
  if hostOS != "macosx":
    echo_skip "Not on macOS."
    return

  selfExec("brewCask")
  selfExec("brewMas")
