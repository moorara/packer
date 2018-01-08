#!/bin/bash

#
# This script provisions cloud instances for beging tested.
# USAGE:
#   --aws           AWS variable files
#   --google        Google cloud variables file
#   --account       Google cloud credential file
#   -m, --manifest  Packer manifest file
#   -t, --tests     Tests specifications file
#

set -euo pipefail

source "./aws/aws.sh"
source "./google/google.sh"
source "../scripts/util.sh"


function parse_args {
  while [[ $# > 1 ]]; do
    key="$1"
    case $key in
      --aws)
      aws_file="$2"
      shift
      ;;
      --google)
      google_file="$2"
      shift
      ;;
      --account)
      google_account_file="$2"
      shift
      ;;
      -m|--manifest)
      manifest_file="$2"
      shift
      ;;
      -t|--tests)
      tests_file="$2"
      shift
      ;;
    esac
    shift
  done
}

function cleanup {
  cleanup_aws_resources
  cleanup_google_resources
}


parse_args "$@"
ensure_command "jq" "aws" "terraform"
ensure_json_file "$aws_file" "$google_file" "$google_account_file" "$manifest_file" "$tests_file"

aws_access_key=$(jq -r '.aws_access_key' $aws_file)
aws_secret_key=$(jq -r '.aws_secret_key' $aws_file)
aws_region=$(jq -r '.builds[] | select(.builder_type == "amazon-ebs") | .artifact_id' $manifest_file | cut -d ':' -f 1)
aws_ami=$(jq -r '.builds[] | select(.builder_type == "amazon-ebs") | .artifact_id' $manifest_file | cut -d ':' -f 2)

google_project_id=$(jq -r '.google_project_id' $google_file)
google_image=$(jq -r '.builds[] | select(.builder_type == "googlecompute") | .artifact_id' $manifest_file)

trap cleanup EXIT

if [ ! -z $aws_ami ]; then
  cd aws
  main_aws $aws_access_key $aws_secret_key $aws_region $aws_ami $tests_file
  cd ..
fi

if [ ! -z $google_image ]; then
  cd google
  main_google $google_account_file $google_project_id $google_image $tests_file
  cd ..
fi
