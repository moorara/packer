#!/usr/bin/env bash

#
# This file contains a set of functions for running aws tests.
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'

flag_aws_active=false


function generate_aws_keys {
  printf "${blue}GENERATING NEW SSH KEYS FOR AWS ...${nocolor}\n"

  rm -f packer-test.pem packer-test.pub
  ssh-keygen -f packer-test -t rsa -N '' 1> /dev/null
  mv packer-test packer-test.pem
  chmod 400 packer-test.pem
}

function provision_aws_resources {
  printf "${blue}SPINNING UP A NEW AWS INSTANCE WITH $aws_ami${nocolor}\n"

  aws_access_key=$1
  aws_secret_key=$2
  aws_region=$3
  aws_ami=$4

  terraform init 1> /dev/null
  terraform apply \
    -input=false \
    -var "aws_access_key=$aws_access_key" \
    -var "aws_secret_key=$aws_secret_key" \
    -var "aws_region=$aws_region" \
    -var "aws_ami=$aws_ami" \
    1> /dev/null

  flag_aws_active=true

  aws_instance_id=$(jq -r '.modules[0].outputs.aws_instance_id.value' terraform.tfstate)
  aws_instance_ip=$(jq -r '.modules[0].outputs.aws_instance_ip.value' terraform.tfstate)
  printf "${purple}  Instance ID: $aws_instance_id${nocolor}\n"
  printf "${purple}  Instance IP: $aws_instance_ip${nocolor}\n"
}

function wait_for_aws_ready {
  printf "${blue}WAITING FOR AWS INSTANCE BE READY ...${nocolor}\n"

  aws_access_key=$1
  aws_secret_key=$2
  aws_region=$3
  aws_instance_id=$4
  aws_instance_status=

  aws configure --profile packer-test set aws_access_key_id $aws_access_key
  aws configure --profile packer-test set aws_secret_access_key $aws_secret_key

  while [ "$aws_instance_status" != "ok" ]; do
    sleep 20
    aws_instance_status=$(
      aws --profile packer-test --region $aws_region \
        ec2 describe-instance-status --instance-id $aws_instance_id \
      | jq -r '.InstanceStatuses[0].InstanceStatus.Status'
    )
    printf "${blue}  Instance Status: $aws_instance_status${nocolor}\n"
  done
}

function run_aws_tests {
  printf "${blue}RUNNING TESTS AGAINST AWS INSTANCE ...${nocolor}\n"

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

function cleanup_aws_resources {
  if [ "$flag_aws_active" != true ] ; then
    return
  fi

  printf "${blue}CLEANING UP AWS TEST RESOURCES ...${nocolor}\n"

  aws_access_key=${1:-$aws_access_key}
  aws_secret_key=${2:-$aws_secret_key}
  aws_region=${3:-$aws_region}
  aws_ami=${4:-$aws_ami}

  terraform destroy \
    -force \
    -var "aws_access_key=$aws_access_key" \
    -var "aws_secret_key=$aws_secret_key" \
    -var "aws_region=$aws_region" \
    -var "aws_ami=$aws_ami" \
    1> /dev/null

  rm -rf \
    packer-test.pem packer-test.pub \
    .terraform terraform.tfstate terraform.tfstate.backup

  flag_aws_active=false
}

function main_aws {
  aws_access_key=$1
  aws_secret_key=$2
  aws_region=$3
  aws_ami=$4
  tests_file=$5

  generate_aws_keys
  provision_aws_resources $aws_access_key $aws_secret_key $aws_region $aws_ami
  wait_for_aws_ready $aws_access_key $aws_secret_key $aws_region $aws_instance_id
  run_aws_tests $aws_instance_ip $tests_file
  cleanup_aws_resources $aws_access_key $aws_secret_key $aws_region $aws_ami
}
