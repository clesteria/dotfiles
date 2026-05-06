task portsInstall, "Install MacPorts (macOS only)":
  echo_section "Install MacPorts"

  if hostOS != "macosx":
    echo_skip "Not on macOS."
    return

  if gorgeEx("command -v port").exitCode == 0:
    echo_skip "MacPorts is already installed."
    return

  let url = getLatestTarBall("macports", "macports-base")
  if url == "":
    echo_error "URL not found."
    return

  echo_message "Download archive."
  let filename = url.extractFilename
  discard safeExec("curl -sLO " & url)
  if not fileExists(filename):
    echo_error "Download failed."
    return

  discard safeExec("tar xjf " & filename)
  var dirname = thisDir() / filename
  dirname.removeSuffix(".tar.bz2")

  echo_message "configure & make install."
  withDir dirname:
    exec("./configure && make && sudo make install")

  discard safeExec("rm -fr " & dirname & "*")

  if fileExists("/opt/local/bin/port"):
    echo_message "MacPorts Installed."
  else:
    echo_error "Install failed."

task ports, "Sync MacPorts packages (macOS only)":
  echo_section "Syncing MacPorts"

  if hostOS != "macosx":
    echo_skip "Not on macOS"
    return

  let portsFile = dataDir / "Portsfile.json"
  let nodes = readJsonFile(portsFile)

  let packages = nodes.elems
    .mapIt(it["Packages"].elems.mapIt(it.getStr()))
    .concat()
    .toHashSet()

  let res = gorgeEx("port installed")
  if res.exitCode != 0:
    return
  let installedRaw = res.output
  let installed = installedRaw.splitLines()
    .filterIt(it.contains("@"))
    .mapIt(it.strip().split(' ')[0])
    .toHashSet()

  let novariantPackages = packages.mapIt(it.split(' ')[0]).toHashSet()
  let missing = novariantPackages - installed
  if missing.len == 0:
    echo_skip "All ports are already installed."
    return
  echo_message "Update MacPorts."
  let resUpdate = safeExec("sudo port selfupdate")
  if resUpdate.exitCode != 0:
    echo_error "Update failed."
    return

  echo_message "Install packages."
  for package in missing:
    echo_info "Install: " & package
    discard safeExec("sudo port install " & package)

task portsUpdate, "Update MacPorts & packages (macOS only)":
  echo_section "Updating MacPorts"

  if hostOS != "macosx":
    echo_skip "Not on macOS"
    return

  echo_message "Update MacPorts."
  let resUpdate = safeExec("sudo port selfupdate")
  if resUpdate.exitCode != 0:
    echo_error "Update failed."
    return

  echo_message "Update packages."
  discard safeExec("sudo port upgrade outdated")
