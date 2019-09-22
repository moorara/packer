#!/bin/bash

#
# Provisioning script for Fedora images:
# This script is used for installing/updating required packages and files.
#

set -euo pipefail

source "/tmp/scripts/provision.sh"


# Update all packages and install tools
dnf update  -y
dnf install -y  tar zip unzip vim curl git jq

# Install docker and docker-compose
install_docker "fedora"
install_docker_compose

# Clean up image
# dnf autoremove -y
dnf clean all
rm -rf /tmp/*
