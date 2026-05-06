import std/[os, strutils, json, sequtils, sets]

--hints:off

const
  dataDir = "manifests"

# Utilities

proc getTerminalWidth(): int =
  let res = gorgeEx("stty size < /dev/tty")
  if res.exitCode == 0:
    let parts = res.output.strip().splitWhitespace()
    if parts.len >= 2:
      try:
        return parts[1].parseInt()
      except:
        discard
  return 80

proc echo_section(msg: string) =
  let width = getTerminalWidth()
  echo "┌" & "─".repeat(width - 1)
  echo "│ " & msg
  echo "└" & "─".repeat(width - 1)

proc echo_message(msg: string) =
  exec("printf \"\\033[1;36m==> " & msg & "\\033[0m\\n\"")

proc echo_info(msg: string) =
  exec("printf \"\\033[32m" & msg & "\\033[0m\\n\"")

proc echo_caution(msg: string) =
  exec("printf \"\\033[33mCaution: " & msg & "\\033[0m\\n\"")

proc echo_error(msg: string) =
  exec("printf \"\\033[31mError: " & msg & "\\033[0m\\n\"")

proc echo_skip(msg: string) =
  exec("printf \"\\033[34mSkipping: " & msg & "\\033[0m\\n\"")

proc safeExec(cmd: string): tuple[output: string, exitCode: int] =
  result = gorgeEx(cmd)
  if result.exitCode != 0:
    echo_error "Command failed: " & cmd

proc getLatestTarBall(owner, repo: string): string =
  let api = "https://api.github.com/repos/" & owner & "/" & repo & "/releases/latest"
  let res = gorgeEx("curl -sL -H \"Accept: application/vnd.github+json\" " & api)
  if res.exitCode == 0:
    try:
      let data = parseJson(res.output)
      if not data.hasKey("assets"):
        return ""
      for asset in data["assets"]:
        let url = asset["browser_download_url"].getStr()
        if url.endsWith(".tar.bz2"):
          return url
    except:
      echo "Error parsing JSON response"
  return ""

proc readJsonFile(path: string): JsonNode =
  if not fileExists(path):
    quit(path & " not found.", 1)

  let raw = readFile(path)
  result = parseJson(raw)

# Tasks

include ".nims/symlink.nims"
include ".nims/macports.nims"
include ".nims/homebrew.nims"
include ".nims/defaults.nims"

task build, "Install management tools":
  if hostOS == "macosx":
    selfExec "portsInstall"
    selfExec "brewInstall"

task install, "Setup":
  selfExec "symlink"
  if hostOS == "macosx":
    selfExec "ports"
    selfExec "brew"
    selfExec "defaults"

task update, "Update":
  selfExec "symlink"
  if hostOS == "macosx":
    selfExec "portsUpdate"
    selfExec "brew"
