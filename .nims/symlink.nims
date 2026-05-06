task symlink, "Create symbolic links for dotfiles":
  echo_section "Create symbolic links"

  let targetDirs = @["sh", "vim", "git"]
  let homeDir = getHomeDir()

  for dirName in targetDirs:
    let configDir = getCurrentDir() / dirName

    for kind, path in walkDir(configDir):
      if kind != pcFile:
        continue
 
      let name = path.extractFilename
      if not name.startsWith("."):
        continue

      let dest = homeDir / name
      let res = safeExec("ln -snfv " & path & " " & dest)
      if res.exitCode == 0:
        echo_info "Create: " & path.replace(homeDir, "~/") & " -> ~/" & name
