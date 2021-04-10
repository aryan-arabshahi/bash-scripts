#!/usr/bin/env bash

get_os_id() {
    echo $(cat /etc/os-release | grep -w "ID=*" | sed 's/ID=//g')
}

abort() {
    MESSAGE=$1
    if [[ !(-z $MESSAGE) ]]; then
        echo -e $MESSAGE
    fi
    exit 1;
}

check_root_access() {
    if [[ $EUID -ne 0 ]]; then
        abort "\n[!] Run script as root.\n"
    fi
}

install_on_debian() {

    echo -e "\n[+] Installing Docker\n"

    apt update && apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/debian/gpg | \
        gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update && apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io

    echo -e "\n[+] Installing docker-compose\n"

    curl -L \
        "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose

    return 0
}

# Abort script if there is no root access
check_root_access

case $(get_os_id) in
    debian )
        install_on_debian
        ;;
    * )
        abort "[-] Unknown OS!"
        ;;
esac
