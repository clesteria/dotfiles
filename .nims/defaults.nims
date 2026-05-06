task defaults, "Set macOS defaults (macOS only)":
  echo_section "Setting macOS defaults"

  if hostOS != "macosx":
    echo_skip "Not on macOS"
    return

  let defaultsFile = dataDir / "defaults.json"
  let nodes = readJsonFile(defaultsFile)

  for node in nodes:
    let cmd = "defaults write " & node["domain"].getStr() & " " & node["key"].getStr() & " -" & node["type"].getStr() & " " & node["value"].getStr()
    echo_info cmd
    discard safeExec(cmd)

  discard safeExec("killall Dock")
  discard safeExec("killall Finder")
  discard safeExec("killall SystemUIServer")
