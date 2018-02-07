.PHONY: all dotfiles

all: dotfiles

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  ALACRITTY := .alacritty-linux.yml
endif
ifeq ($(UNAME_S),Darwin)
  ALACRITTY := .alacritty-osx.yml
endif

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg" -not -name ".work*" -not -name ".alacritty*"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	ln -sfn $(CURDIR)/$(ALACRITTY) $(HOME)/.alacritty.yml
	ln -sfn $(CURDIR)/$(ALACRITTY) $(HOME)/.config/alacritty/alacritty.yml

work:
	ln -sfn $(CURDIR)/.work_liveramp $(HOME)/.work
