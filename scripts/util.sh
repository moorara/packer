#!/usr/bin/env bash

#
# This file contains a set of utility functions.
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'


function whitelist_variable {
  if [[ ! $2 =~ (^|[[:space:]])$3($|[[:space:]]) ]]; then
    printf "${red}Invalid $1 $3${nocolor}\n"
    exit 1
  fi
}

function ensure_command {
  for cmd in $@; do
    which $cmd 1> /dev/null || (
      printf "${red}$cmd not available!${nocolor}\n"
      exit 2
    )
  done
}

function ensure_env_var {
  for var in $@; do
    if [ "${!var}" == "" ]; then
      printf "${red}$var is not set.${nocolor}\n"
      exit 3
    fi
  done
}

function ensure_json_file {
  for file in $@; do
    if [ ! -f $file ]; then
      printf "${red}$file not found!${nocolor}\n"
      exit 4
    fi
    jq '.' $file 1> /dev/null || (
      printf "${red}$file not json!${nocolor}\n"
      exit 5
    )
  done
}
