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
	mkdir -p $(HOME)/.gnupg
	ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	ln -sfn $(CURDIR)/$(ALACRITTY) $(HOME)/.alacritty.yml
	mkdir -p $(HOME)/.config/alacritty
	ln -sfn $(CURDIR)/$(ALACRITTY) $(HOME)/.config/alacritty/alacritty.yml

work:
	ln -sfn $(CURDIR)/.work_liveramp $(HOME)/.work

.PHONY: test
test: shellcheck ## Runs all the tests on the files in the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		julianvmodesto/shellcheck ./test.sh
