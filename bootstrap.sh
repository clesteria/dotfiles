#!/usr/bin/env bash
set -ue

# gitの確認
if ! which git >/dev/null 2>&1; then
  echo "git not found."
  exit 1
fi

# リポジトリのクローン
DOTDIR="${HOME}/.dotfiles"
if [ ! -d "${DOTDIR}" ]; then
  git clone https://github.com/clesteria/dotfiles.git "$DOTDIR"
fi

# macOSはインストールスクリプト実行
cd "${DOTDIR}"
case "$(uname)" in
Darwin) ./install_macos.sh ;;
*) echo "Unsupported OS" ;;
esac

# シンボリックリンクの作成
./create_link.sh
