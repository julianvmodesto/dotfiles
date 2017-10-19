#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# bash vi editting
# http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/
set -o vi

# https://www.topbug.net/blog/2016/09/27/make-gnu-less-more-powerful/
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'
# Set colors for less. Borrowed from https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
  elif command -v brew > /dev/null && [[ -f $(brew --prefix)/etc/bash_completion  ]]; then
    # macOS
    # shellcheck source=/dev/null
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# Google Cloud SDK
if command -v brew > /dev/null && [[ -f $(brew --prefix)/Caskroom/google-cloud-sdk  ]]; then
  # macOS
  # shellcheck source=/dev/null
  . $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc
  # shellcheck source=/dev/null
  . $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
fi

# Kubernetes
if command -v kubectl > /dev/null; then
  # shellcheck source=/dev/null
  source <(kubectl completion bash)
fi

# fzf
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

# Node
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
[[ -s "${NVM_DIR}/bash_completion" ]] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion

# Go
[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"

# Ruby
command -v rbenv > /dev/null && eval "$(rbenv init -)"

SSHAGENT=$(which ssh-agent)
SSHAGENTARGS="-s"
if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT"  ]; then
  eval `$SSHAGENT $SSHAGENTARGS`
  trap "kill $SSH_AGENT_PID" 0
  case "$(uname)" in
    Darwin)
      ssh-add -K ~/.ssh/
    ;;
    Linux)
      ssh-add -L ~/.ssh/
    ;;
  esac
fi

if [[ -e ~/.work ]] && [[ -f ~/.work ]] && [[ -r ~/.work ]]; then
  # shellcheck source=/dev/null
  source ~/.work
fi

