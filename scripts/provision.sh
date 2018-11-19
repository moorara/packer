#!/usr/bin/env bash

#
# This file contains a set of common functions for provisioning scripts.
#
# USAGE:
#   source "path/to/provision.sh"
#

set -euo pipefail


function install_docker {
  user=$1

  curl -fsSL https://get.docker.com | sh
  groupadd docker || true
  usermod -aG docker $user
  systemctl enable docker
}

function install_docker_compose {
  release=1.23.1

  compose_path=/usr/bin/docker-compose
  curl -fsSL -o $compose_path https://github.com/docker/compose/releases/download/$release/docker-compose-Linux-x86_64
  chmod 755 $compose_path
}
