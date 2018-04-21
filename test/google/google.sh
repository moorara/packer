#!/usr/bin/env bash

#
# This file contains a set of functions for running google cloud tests.
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'

flag_google_active=false


function generate_google_keys {
  printf "${blue}GENERATING NEW SSH KEYS FOR GOOGLE ...${nocolor}\n"

  ssh_user=$1

  rm -f packer-test.pem packer-test.pub
  ssh-keygen -f packer-test -t rsa -N '' -C $ssh_user 1> /dev/null
  mv packer-test packer-test.pem
  chmod 400 packer-test.pem
}

function provision_google_resources {
  printf "${blue}SPINNING UP A NEW GOOGLE INSTANCE WITH $google_image${nocolor}\n"

  google_account_file=$1
  google_project_id=$2
  google_image=$3
  ssh_user=$4

  terraform init 1> /dev/null
  terraform apply \
    -auto-approve \
    -input=false \
    -var "google_account_file=$google_account_file" \
    -var "google_project_id=$google_project_id" \
    -var "google_image=$google_image" \
    -var "google_ssh_user=$ssh_user" \
    1> /dev/null

  sleep 60
  flag_google_active=true

  google_instance_ip=$(jq -r '.modules[0].outputs.google_instance_ip.value' terraform.tfstate)
  printf "${purple}  Instance IP: $google_instance_ip${nocolor}\n"
}

function wait_for_google_ready {
  printf "${blue}WAITING FOR GOOGLE INSTANCE BE READY ...${nocolor}\n"

  sleep 60
}

function run_google_tests {
  printf "${blue}RUNNING TESTS AGAINST GOOGLE INSTANCE ...${nocolor}\n"

  instance_ip=$1
  tests_file=$2
  tests_spec=$(cat $tests_file)
  ssh_user=$(echo $tests_spec | jq -r '.ssh_user')

  # Iterate over test cases
  tests_count=$(echo $tests_spec | jq ".tests | length")
  for (( i=0; i<$tests_count; i++ )); do
    test_command=$(echo $tests_spec | jq -r ".tests[$i].command")
    printf "${yellow}  $test_command${nocolor}\n"

    test_output=$(ssh -i packer-test.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l $ssh_user $instance_ip $test_command 2> /dev/null)
    printf "${yellow}    $test_output${nocolor}\n"

    test_expected_count=$(echo $tests_spec | jq ".tests[$i].expected | length")
    for (( j=0; j<$test_expected_count; j++ )); do
      test_expected=$(echo $tests_spec | jq -r ".tests[$i].expected[$j]")
      test_result=$(echo $test_output | grep -oe "$test_expected")
      printf "${green}      [✓] $test_result${nocolor}\n"
    done
  done
}

function cleanup_google_resources {
  if [ "$flag_google_active" != true ] ; then
    return
  fi

  printf "${blue}CLEANING UP GOOGLE TEST RESOURCES ...${nocolor}\n"

  google_account_file=${1:-$google_account_file}
  google_project_id=${2:-$google_project_id}
  google_image=${3:-$google_image}
  ssh_user=${4:-$ssh_user}

  terraform destroy \
    -auto-approve \
    -var "google_account_file=$google_account_file" \
    -var "google_project_id=$google_project_id" \
    -var "google_image=$google_image" \
    -var "google_ssh_user=$ssh_user" \
    1> /dev/null

  rm -rf \
    packer-test.pem packer-test.pub \
    .terraform terraform.tfstate terraform.tfstate.backup

  flag_google_active=false
}

function main_google {
  google_account_file=$1
  google_project_id=$2
  google_image=$3
  tests_file=$4
  ssh_user=$(jq -r '.ssh_user' $tests_file)

  generate_google_keys $ssh_user
  provision_google_resources $google_account_file $google_project_id $google_image $ssh_user
  wait_for_google_ready
  run_google_tests $google_instance_ip $tests_file
  cleanup_google_resources $google_account_file $google_project_id $google_image $ssh_user
}
