#!/bin/bash
set -e

check_is_sudo() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root."
		exit
	fi

}

# sets up apt sources
setup_sources() {
	apt-get update
	apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		dirmngr \
		--no-install-recommends
	cat <<-EOF > /etc/apt/sources.list
        deb http://archive.ubuntu.com/ubuntu xenial main universe
        deb http://security.ubuntu.com/ubuntu/ xenial-security universe main
        deb http://archive.ubuntu.com/ubuntu xenial-updates universe main

        # Neovim
        deb http://ppa.launchpad.net/neovim-ppa/stable/ubuntu xenial main
        deb-src http://ppa.launchpad.net/neovim-ppa/stable/ubuntu xenial main

        # Docker
        deb https://apt.dockerproject.org/repo ubuntu-xenial main

        # Git LFS
        deb https://packagecloud.io/github/git-lfs/ubuntu/ xenial main

        # Yarn
        deb https://dl.yarnpkg.com/debian/ stable main
	EOF

	# Add the Cloud SDK distribution URI as a package source
	echo "deb https://packages.cloud.google.com/apt cloud-sdk-sid main" > /etc/apt/sources.list.d/google-cloud-sdk.list

	# Import the Google Cloud Platform public key
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

	# add the neovim ppa gpg key
	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 9DBB0BE9366964F134855E2255F96FCF8231B6DD

    # Add Git LFS PGP key
    wget -q -O- https://packagecloud.io/gpg.key | sudo apt-key add -

    # Add Docker PGP key.
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

    # Add Yarn
    wget -q -O- https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

	# turn off translations, speed up apt-get update
	mkdir -p /etc/apt/apt.conf.d
	echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99translations
}

base() {
  apt-get update
  apt-get -y upgrade

  apt-get install -y \
    apparmor \
    apparmor-utils \
    bash-completion \
    bison \
    build-essential \
    coreutils \
    docker-engine \
    git \
    git-lfs \
    google-cloud-sdk \
    htop \
    jq \
    less \
    moreutils \
    neovim \
    shellcheck \
    tmux \
    whois \
    xclip \
    yarn

  install_docker
}

base_macos() {
    if [ -z "$(which brew)" ]; then
        echo -e "\nInstalling homebrew...\n"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew install \
      bash-completion \
      kubectl \
      neovim/neovim/neovim

    brew cask install google-cloud-sdk
    # brew cask install dnscrypt
}

install_vim() {
	# create subshell
	(
	cd "$HOME"

	# install .vim files
	git clone --recursive https://github.com/julianvmodesto/.vim.git "${HOME}/.vim"
	ln -snf "${HOME}/.vim/vimrc" "${HOME}/.vimrc"

	# alias vim dotfiles to neovim
	mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"
	ln -snf "${HOME}/.vim" "${XDG_CONFIG_HOME}/nvim"
	ln -snf "${HOME}/.vimrc" "${XDG_CONFIG_HOME}/nvim/init.vim"

	# do the same for root
    if [[ -d /root ]]; then
        echo "here"
        sudo mkdir -p /root/.config
        sudo ln -snf "${HOME}/.vim" /root/.config/nvim
        sudo ln -snf "${HOME}/.vimrc" /root/.config/nvim/init.vim
    elif [[ -d /var/root ]]; then
        echo "HERE"
        sudo mkdir -p /var/root/.config
        sudo ln -snf "${HOME}/.vim" /var/root/.config/nvim
        sudo ln -snf "${HOME}/.vimrc" /var/root/.config/nvim/init.vim
    fi

    if command -v update-alternatives; then
        # update alternatives to neovim
        sudo update-alternatives --install /usr/bin/vi vi "$(which nvim)" 60
        sudo update-alternatives --config vi
        sudo update-alternatives --install /usr/bin/vim vim "$(which nvim)" 60
        sudo update-alternatives --config vim
        sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 60
        sudo update-alternatives --config editor
    fi
	)
}

install_docker() {
	# create docker group
	sudo groupadd docker
    sudo usermod -aG docker "$(whoami)"

	# update grub with docker configs and power-saving items
	sudo sed -i.bak 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 pcie_aspm=force apparmor=1 security=apparmor"/g' /etc/default/grub
	echo "Docker has been installed. If you want memory management & swap"
	echo "run update-grub & reboot"
}

usage() {
	echo -e "install.sh\n\tThis script installs my basic setup\n"
	echo "Usage:"
	echo "  sources                     - setup sources & install base pkgs"
	echo "  dotfiles                    - get dotfiles"
	echo "  vim                         - install vim specific dotfiles"
	echo "  golang                      - install golang and packages"
	echo "  scripts                     - install scripts"
}

main() {
	local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

	if [[ $cmd == "sources" ]]; then
		check_is_sudo

		# setup /etc/apt/sources.list
		setup_sources

		base
	elif [[ $cmd == "macos" ]]; then
        base_macos
	elif [[ $cmd == "dotfiles" ]]; then
		get_dotfiles
	elif [[ $cmd == "vim" ]]; then
		install_vim
	elif [[ $cmd == "golang" ]]; then
		install_golang "$2"
	elif [[ $cmd == "scripts" ]]; then
		install_scripts
	else
		usage
	fi
}

main "$@"
