#!/bin/bash

#
# Provisioning script for Debian images:
# This script is used for installing/updating required packages and files.
#

set -euo pipefail

source "/tmp/scripts/provision.sh"


# Update all packages and install tools
apt-get update
apt-get upgrade -y
apt-get install -y  build-essential
apt-get install -y  tar zip unzip vim curl git jq

# Install docker and docker-compose
install_docker "admin"
install_docker_compose

# Clean up image
apt-get autoremove -y
apt-get clean -y
rm -rf /tmp/*
