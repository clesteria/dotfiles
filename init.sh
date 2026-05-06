#!/usr/bin/env bash
set -ue

GITDOMAIN="github.com"
GITACCOUNT="clesteria"
GITREPO="dotfiles"

# Check git
if ! command -v git >/dev/null 2>&1; then
  echo "git not found."
  exit 1
fi

# Clone repository
DOTDIR="${HOME}/.dotfiles"
if [ ! -d "${DOTDIR}" ]; then
  mkdir -p ${DOTDIR}
  git clone https://${GITDOMAIN}/${GITACCOUNT}/${GITREPO}.git "${DOTDIR}"
fi

# Setting OS tools
case "$(uname -s)" in
Darwin)
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    while :; do
      sleep 10
      xcode-select -p >/dev/null 2>&1 && break
    done
  fi
  ;;
Linux) ;;
*)
  echo "Unsupported OS: $(uname -s)"
  ;;
esac

# Install nim(choosenim)
if ! command -v nim >/dev/null 2>&1; then
  echo "Installing Nim via choosenim..."
  curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
  export PATH="${HOME}/.nimble/bin:${PATH}"
  if ! command -v nim >/dev/null 2>&1; then
    echo "nim not found."
    exit 2
  fi
fi

# Run setting task
cd ${DOTDIR}
nim build
nim install
