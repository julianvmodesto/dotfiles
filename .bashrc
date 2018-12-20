#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

set -o pipefail

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"
    ;;
  *)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
  fi
  if [[ -f /etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
  fi
  if [[ -f /usr/local/etc/bash_completion ]]; then
      # shellcheck source=/dev/null
      . /usr/local/etc/bash_completion
  fi
fi

# This function checks whether we have a given program on the system.
#
_have()
{
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &>/dev/null
}
# Backwards compatibility for compat completions that use have().
# @deprecated should no longer be used; generally not needed with dynamically
#             loaded completions, and _have is suitable for runtime use.
have()
{
    unset -v have
    _have $1 && have=yes
}
if [[ -d /etc/bash_completion.d ]]; then
  for file in /etc/bash_completion.d/* ; do
    # shellcheck disable=
    source "$file"
  done
fi
if [[ -d /usr/share/bash-completion/completions ]]; then
  for file in /usr/share/bash-completion/completions/* ; do
    # shellcheck disable=
    source "$file"
  done
fi

# SSH autocompletion
# https://unix.stackexchange.com/a/181603
_ssh()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

  COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
  return 0
}
complete -F _ssh ssh

# bash vi editting
# http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/
set -o vi

if ! [[ -n "${SSH_CLIENT}" ]] && ! [[ -n "${SSH_TTY}" ]]; then
  # Start the gpg-agent if not already running
  if command -v gpg-connect-agent > /dev/null && ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
    gpg-connect-agent /bye >/dev/null 2>&1
    gpg-connect-agent updatestartuptty /bye >/dev/null
  fi
  # use a tty for gpg
  # solves error: "gpg: signing failed: Inappropriate ioctl for device"
  GPG_TTY=$(tty)
  export GPG_TTY
  # Set SSH to use gpg-agent
  unset SSH_AGENT_PID
  GPG_SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"
  if [[ -S "${GPG_SSH_AUTH_SOCK}" ]]; then
    export SSH_AUTH_SOCK="${GPG_SSH_AUTH_SOCK}"
  elif [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
  fi
  # add alias for ssh to update the tty
  alias ssh="gpg-connect-agent updatestartuptty /bye >/dev/null; ssh"
  export GIT_SSH_COMMAND="gpg-connect-agent updatestartuptty /bye >/dev/null; ssh"

  if command -v git > /dev/null; then
    git config --global url.ssh://git@github.com:julianvmodesto/.insteadOf https://github.com/julianvmodesto/
  fi

  if [[ -S "/var/run/dbus/system_bus_socket" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="/var/run/dbus/system_bus_socket"
  fi

fi
