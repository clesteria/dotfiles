## set zshrc (via https://gist.github.com/mollifier/4979906)
ZSHRC_USEFUL="${HOME}/zshrc_useful.sh"
test -f "${ZSHRC_USEFUL}" && source ${ZSHRC_USEFUL}

## set PROMPT
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' formats '%F{green}(%b)%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%b|%a)%f'

function _update_vcs_info_msg() {
  LANG=en_US.UTF-8 vcs_info
  PROMPT="%{${fg[yellow]}%}[%D{%Y/%m/%d} %*]%{${reset_color}%} %{${fg[cyan]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
%# "
}

add-zsh-hook precmd _update_vcs_info_msg

## set brew tools
export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
export MANPATH="/usr/local/share/man:${MANPATH}"

## set GNU tools

### coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"

### findutils
export PATH="/usr/local/opt/findutils/libexec/gnubin:${PATH}"
export MANPATH="/usr/local/opt/findutils/libexec/gnuman:${MANPATH}"

### gnu-sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin/:${PATH}"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnubin/:${MANPATH}"
alias sed='gsed'

## set direnv
export EDITOR=vim
eval "$(direnv hook zsh)"

## set exa
alias ls='exa'
alias ll='exa -lah --git --time-style full-iso'

## set rust
export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

## set rbenv
eval "$(rbenv init -)"

## set ghq
Set-GitLocation () {
  GHQROOT="$(ghq root)"
  GHQDIR="$(ghq list | peco)"
  test -z "${GHQDIR}" && return
  test -d "${GHQROOT}/${GHQDIR}" || return
  cd ${GHQROOT}/${GHQDIR}
}
alias g='Set-GitLocation'
