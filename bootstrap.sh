#!/usr/bin/env sh

continue_as_user() {
    printf "\nPrerequisites installed. Now run:\nansible-pull -U https://github.com/cconrad/ansible-pull.git\n"
}

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run using sudo or as root"
  exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
    OS=Debian
elif [ -f /etc/redhat-release ]; then
    OS=RHEL
else
    OS=$(uname -s)
fi

case $OS in
    arch)
        # TODO Check if the package(s) are already installed
        if pacman -Sy --noconfirm ansible-core git ; then continue_as_user ; fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac