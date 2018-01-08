#!/bin/bash

#
# Provisioning script for CentOS images:
# This script is used for installing/updating required packages and files.
#

set -euo pipefail

source "/tmp/scripts/provision.sh"


# Update all packages and install tools
yum update  -y
yum install -y  tar zip unzip vim curl git jq

# Install docker and docker-compose
install_docker "centos"
install_docker_compose

# Clean up image
yum autoremove -y
yum clean all
rm -rf /tmp/*
