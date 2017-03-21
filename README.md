# dotfiles
My dotfiles

# TODO
- make a Makefile
- pre-install, install, post-install instructions
- figure out how to handle git-crypt in git submodules

# Pre Reqs

- Dashlane
- git
- iTerm
- Homebrew
- Keybase
- GPG
- Slack
- Alfred
- Bartender
- Dropbox
- Dash
- itsycal

```
brew install git-crypt
brew install thefuck
brew install neovim/neovim/neovim
brew install ripgrep
brew install git-lfs
brew install watch
brew install jenv
brew install shellcheck
brew install yarn
```

nvim
- Anaconda
- nvm


- gvm

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

# Software
## Essentials
## Nice To Have
- [XKCD password generator](https://github.com/redacted/XKCD-password-generator)
