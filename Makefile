.PHONY: all
all: bin dotfiles etc ## Installs the bin and etc directory files and the dotfiles.

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  ALACRITTY := .alacritty-linux.yml
endif
ifeq ($(UNAME_S),Darwin)
  ALACRITTY := .alacritty-osx.yml
endif

XDG_CONFIG_HOME ?= "${HOME}/.config"
XDG_DATA_HOME ?= "${HOME}/.local/share"

.PHONY: bin
bin: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done

.PHONY: dotfiles
dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".work" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".gitattributes" -not -name ".*.swp" -not -name ".gnupg" -not -name ".alacritty*" -not -name ".synergy*"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	mkdir -p ${XDG_DATA_HOME};
	mkdir -p ${XDG_CONFIG_HOME};
	mkdir -p $(HOME)/.gnupg
	ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	ln -sfn $(CURDIR)/.gnupg/scdaemon.conf $(HOME)/.gnupg/scdaemon.conf;
	ln -snf $(CURDIR)/.bash_profile $(HOME)/.profile;
	ln -snf $(CURDIR)/.i3 ${XDG_CONFIG_HOME}/sway;
	ln -snf $(CURDIR)/.fonts ${XDG_DATA_HOME}/fonts;
	if [ -f /usr/local/bin/pinentry ]; then \
		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	fi;
	ln -sfn $(CURDIR)/$(ALACRITTY) $(HOME)/.alacritty.yml
	mkdir -p ${XDG_CONFIG_HOME}/alacritty
	ln -sfn $(CURDIR)/$(ALACRITTY) ${XDG_CONFIG_HOME}/alacritty/alacritty.yml
	mkdir -p $(HOME)/.icons/default
	mkdir -p ${XDG_CONFIG_HOME}/git
	ln -sfn $(CURDIR)/.gitattributes ${XDG_CONFIG_HOME}/git/attributes

.PHONY: etc
etc: ## Installs the etc directory files.
	sudo mkdir -p /etc/docker/seccomp
	getent group docker || sudo groupadd docker
	sudo chown -R $(USER):docker /etc/docker
	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
		sudo ln -f $$file $$f; \
	done
	systemctl --user daemon-reload || true
	sudo systemctl daemon-reload
	sudo systemctl enable suspend-sedation.service
	sudo systemctl disable suspend-then-hibernate.target

.PHONY: work
work:
	ln -sfn $(CURDIR)/.work $(HOME)/.work
	ln -sfn $(CURDIR)/.synergy.work.conf $(HOME)/.synergy.conf

.PHONY: synergy
synergy:
	# https://github.com/symless/synergy-core/wiki/Security#linux
	mkdir -p ~/.synergy/SSL/Fingerprints
	openssl req -x509 -nodes -days 365 -subj /CN=Synergy -newkey rsa:1024 -keyout ~/.synergy/SSL/Synergy.pem -out ~/.synergy/SSL/Synergy.pem
	openssl x509 -fingerprint -sha1 -noout -in ~/.synergy/SSL/Synergy.pem > ~/.synergy/SSL/Fingerprints/Local.txt
	sed -e "s/.*=//" -i ~/.synergy/SSL/Fingerprints/Local.txt

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
