#!/usr/bin/env bash

# Based on https://docs.docker.com/engine/install/
# - dropped ansible due to 'NoneType' errors !!
#
#DOCKER_USER=student
DOCKER_USER=wasadmin

die() { echo "$0: die - $*" >&2; exit 1; }

ARCH=$(uname -m)

case $ARCH in
    # multipass on Mac-M1:
      arm64) echo "CPU Architecture: Arm64"; ARCH=aarch64;;
    aarch64) echo "CPU Architecture: Arm64";;
     x86_64) echo "CPU Architecture: Amd64";;

    *) die "Not implemented for architecture '$ARCH'";;
esac

SETUP_CLEAN() {
    echo; echo "==== Removing Docker Packages, Key & Repo"

    PKGS=""
    for PKG in docker.io docker-compose docker-compose-v2 docker-doc podman-docker; do
	dpkg -l | grep "^ii *$PKG " && PKGS+=" $PKG"
    done

    [ ! -z "$PKGS" ] && {
        echo "Packages to remove: '$PKGS'"
        sudo apt-get remove -y $PKGS
    }

    [ -f /etc/apt/keyrings/docker.gpg        ] &&
      sudo rm /etc/apt/keyrings/docker.gpg
    [ -f /etc/apt/sources.list.d/docker.list ] &&
      sudo rm /etc/apt/sources.list.d/docker.list
}

SETUP_ADD_DOCKER_REPO() {
    [ -f /etc/apt/sources.list.d/docker.list ] && return

    echo; echo "==== Adding Docker Key & Repo"

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
       "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
}

SETUP_INSTALL_DOCKER() {
    echo; echo "==== Installing Docker"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

SETUP_ENABLE_DOCKER_USERS() {
    USERS=$*

    echo; echo "==== Check Docker OK as root:"
    sudo docker version

    for _USER in $USERS; do
        echo; echo "==== Check Docker OK as $_USER:"

        sudo usermod -aG docker $_USER
        sudo -u $_USER -i docker version
    done
}

SETUP_GIT_CLONE() {
    mkdir ~/src/
    git clone https://github.com/mjbright/opa-rego-scenarios ~/src/opa-rego-scenarios 
}

INITIAL_SETUP() {
    sudo apt-get install -y curl wget vim git

    SETUP_CLEAN
    SETUP_ADD_DOCKER_REPO
    SETUP_INSTALL_DOCKER
    SETUP_ENABLE_DOCKER_USERS ubuntu $DOCKER_USER
    SETUP_GIT_CLONE
}

GIT_PULL() {
    cd ~/src/opa-rego-scenarios 
        git pull
    cd -
}

USAGE() {
    echo "Usage: $0 [<opt>]"
    echo
    grep -A 20 WHAT_INSTALL $0 | grep -v grep |
         grep -A 20 'case $ARG1' | grep -v case | grep ') ' | grep -v '*) ' |
             grep -v ' *-' |
             sed -e 's/^ *//' -e 's/) /\t/' -e 's/;.*//' -e 's/^/- /'
             #sed -e 's/^ *//' -e 's/) .*//' -e 's/^/    /'
    echo
}

CURL_CONFTEST() {
    local BIN=conftest
    RC=~/.install.${BIN}.sh

    echo "# Run this curl command (in the provided VM) for downloading the $BIN  binary"
    case $ARCH in
        # Assumes on my mac:
        aarch64) URL=https://github.com/open-policy-agent/conftest/releases/download/v0.47.0/conftest_0.47.0_Darwin_arm64.tar.gz;;
        amd64)   URL=https://github.com/open-policy-agent/conftest/releases/download/v0.47.0/conftest_0.47.0_linux_amd64.deb;;
        *)       die "Unsupported architecture '$ARCH'"
    esac
    echo "    curl -sL $URL" | tee $RC; echo; echo "# OR you can souce $RC"
}

CURL_REGAL() {
    local BIN=regal
    RC=~/.install.${BIN}.sh

    echo "# Run this curl command (in the provided VM) for downloading the $BIN  binary"
    case $ARCH in
        # Assumes on my mac:
        aarch64) URL=https://github.com/StyraInc/regal/releases/download/v0.14.0/regal_darwin_arm64;; # to UPDATE !!
        amd64)   URL=https://github.com/StyraInc/regal/releases/download/v0.14.0/regal_Linux_x86_64;;
        *)       die "Unsupported architecture '$ARCH'"
    esac
    echo "    curl -sL $URL" | tee $RC; echo; echo "# OR you can souce $RC"
}

CURL_OPA() {
    local BIN=opa
    local RC=~/.install.${BIN}.sh

    echo "# Run this curl command (in the provided VM) for downloading the $BIN  binary"
    case $ARCH in
        # Assumes on my mac:
        aarch64) URL=https://github.com/open-policy-agent/opa/releases/download/v0.59.0/opa_darwin_arm64_static;;
        amd64)   URL=https://github.com/open-policy-agent/opa/releases/download/v0.59.0/opa_linux_amd64_static;;
        *)       die "Unsupported architecture '$ARCH'"
    esac
    echo "    curl -sL $URL" | tee $RC; echo; echo "# OR you can souce $RC"
}

SEND_SCRIPT() {
    VERSION_FILE=$( dirname $( readlink -f $0 ) )/.INSTALLER.sh.version
    if [ ! -f $VERSION_FILE ]; then
        VERSION=1
    else
        let VERSION=1+$( cat $VERSION_FILE )
    fi
    echo $VERSION > $VERSION_FILE

    echo "URL to download script:"
    curl --upload-file $0 https://transfer.sh/INSTALLER_v${VERSION}.sh
    echo
}

[ $# -eq 0 ] && {
     USAGE; die "Missing option - what do you want to install ?"
 }

# WHAT_INSTALL
while [ $# -ne 0 ]; do
    ARG1=$1
    case $ARG1 in
        init) INITIAL_SETUP;;
         git) GIT_PULL;;
         opa) CURL_OPA;;
     conftest) CURL_CONFTEST;;
       regal) CURL_REGAL;;

       -send) SEND_SCRIPT;;

       -amd*) ARCH=amd64;;
        -x86) ARCH=amd64;;
          -h) USAGE;;
           *) USAGE; die "Missing option - what do you want to install ?";;
    esac
    shift
done


