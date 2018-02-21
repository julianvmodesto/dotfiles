# dotfiles
My dotfiles

# TODO
- make a Makefile
- pre-install, install, post-install instructions
- figure out how to handle git-crypt in git submodules

# Set Up

```
git clone ...
cd ...

git pull && git submodule update --init --recursive

# zsh
ln -sF $HOME/src/dotfiles/zsh "${ZDOTDIR:-$HOME}/.zprezto"

# .gitconfig
ln -sF ~/src/dotfiles/.gitconfig ~/.gitconfig
```

# Post-Install

- Alacritty
- Alfred
- Bartender
- Caffeine
- Dash
- Dashlane
- DNSCrypt
- Dropbox
- Evernote
- FreeSpace
- GPG
- Homebrew
- iStat
- itsycal
- Keybase
- PrivateInternetAccess
- Slack
- Sonos
- uTorrent
- Writeful

