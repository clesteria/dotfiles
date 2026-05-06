# ----------------------------------------
# Common
# ----------------------------------------

## set dotfiles root
test -d "${HOME}/ghq" && DOTFILE="$(find ${HOME}/ghq -name "dotfiles" -type d)" || DOTFILE="${HOME}/.dotfiles"

## set zshrc (via https://gist.github.com/mollifier/4979906)
ZSHRC_USEFUL="${DOTFILE}/sh/zshrc_useful.sh"
test -f "${ZSHRC_USEFUL}" && source ${ZSHRC_USEFUL}

# ----------------------------------------
# OS-specific settings
# ----------------------------------------

## Settings by OS
RUNCOM="${DOTFILE}/sh/$(uname -s | tr "[:upper:]" "[:lower:]")_shrc"
test -f ${RUNCOM} && source ${RUNCOM}

# ----------------------------------------
# Prompt
# ----------------------------------------

## set PROMPT
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' formats '%F{green}(%b)%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%b|%a)%f'

function _update_vcs_info_msg() {
  LANG=en_US.UTF-8 vcs_info
  CURRENTSHELL=$(ps -p $$ | awk '$1~/'$$'/ { print $NF }' | sed -e "s/[^a-zA-Z]//g")
  PROMPT="%{${fg[yellow]}%}[%D{%Y/%m/%d} %*]%{${reset_color}%} %{${fg[magenta]}%}%n@%m%{${reset_color}%} %{${fg[blue]}%}<${CURRENTSHELL}>%{${reset_color}%} %{${fg[cyan]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
%# "
}

add-zsh-hook precmd _update_vcs_info_msg

# ----------------------------------------
# Prompt
# ----------------------------------------

## direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ----------------------------------------
# Prompt
# ----------------------------------------

test -e ${DOTFILE}/sh/apps_shrc && source ${DOTFILE}/sh/apps_shrc
