#!/bin/sh

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
        if pacman -Q git >/dev/null 2>/dev/null; then
            GIT_INSTALLED=1
        else
            if pacman -Sy --noconfirm git; then
                GIT_INSTALLED=1
            fi
        fi

        if pacman -Q ansible-core >/dev/null 2>/dev/null; then
            ANSIBLE_INSTALLED=1
        else
            if pacman -Sy --noconfirm ansible-core; then
                ANSIBLE_INSTALLED=1
            fi
        fi
        ;;
    debian|ubuntu)
        if dpkg-query -W -f='${Status}' git 2>/dev/null | grep -q "install ok installed"; then
            GIT_INSTALLED=1
        else
            if apt update && apt install -y git; then
                GIT_INSTALLED=1
            fi
        fi

        if dpkg-query -W -f='${Status}' ansible 2>/dev/null | grep -q "install ok installed"; then
            ANSIBLE_INSTALLED=1
        else
            if apt update && apt install -y ansible; then
                ANSIBLE_INSTALLED=1
            fi
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

if [ "$GIT_INSTALLED" != 1 ] || [ "$ANSIBLE_INSTALLED" != 1 ];
then
    echo "Failed to install git and/or ansible-core"
    exit 1
else
    printf "\nPrerequisites installed. Now run:\nansible-pull -U https://github.com/cconrad/ansible-pull.git\n"
fi