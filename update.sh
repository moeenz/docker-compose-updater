#!/bin/bash

case $OSTYPE in
    linux-gnu ) :;;
    * ) echo "[ ! ] This script only works for Linux installations" && exit;;
esac

if ! [ -x "$(command -v docker-compose)" ]; then
    echo "[ ! ] docker-compose is not installed.";
    exit;
fi

if ! [ -x "$(command -v jq)" ]; then
    echo "[ * ] Installing jq to parse GitHub API...";
    sudo apt-get -y install jq;
fi

echo "[ * ] Checking latest version...";
compose_repo="docker/compose";
current_version=$(docker-compose --version | egrep -o "([0-9]{1,}\.)+[0-9]{1,}");
latest_stable_version=$(curl -s https://api.github.com/repos/$compose_repo/releases/latest | jq .name -r);
if [ $current_version == $latest_stable_version ]; then
    echo "[ * ] docker-compose is already at it's latest version.";
    exit;
fi

if [ ! -z "$(ps -ef | grep docker-compose)" ]; then
    while true; do
        read -p "[ ? ] docker-compose is currently running. Will you continue? [y/N] " yn;
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "[ ! ] Please answer [y/N]";;
        esac
    done
fi

echo "[ * ] Installing docker-compose version $latest_stable_version...";
output="/usr/local/bin/docker-compose";
sudo curl -L "https://github.com/$compose_repo/releases/download/$latest_stable_version/docker-compose-$(uname -s)-$(uname -m)" -o $output;
sudo chmod +x $output;

echo "[ * ] docker-compose version updated to $latest_stable_version";
exit;
