platforms := aws,google

path := $(shell pwd)
version := $(shell grep -oe '\d\.\d\.\d' VERSION)
build := $(shell date -u +%Y%m%d-%H%M%S)


clean:
	@ rm -rf test/aws/.terraform test/google/.terraform && \
	  rm -f test/aws/terraform.tfstate* test/google/terraform.tfstate* && \
	  rm -f test/aws/*.pem test/aws/*.pub test/google/*.pem test/google/*.pub && \
	  rm -f centos/manifest.json debian/manifest.json ubuntu/manifest.json

centos:
	@ cd centos && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    centos.json

centos-test:
	@ cd test && \
	  ./run.sh \
	    --aws $(path)/aws.json \
	    --google $(path)/google.json \
	    --account $(path)/account.json \
	    --manifest $(path)/centos/manifest.json \
	    --tests $(path)/centos/tests.json

debian:
	@ cd debian && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    debian.json

debian-test:
	@ cd test && \
	  ./run.sh \
	    --aws $(path)/aws.json \
	    --google $(path)/google.json \
	    --account $(path)/account.json \
	    --manifest $(path)/debian/manifest.json \
	    --tests $(path)/debian/tests.json

fedora:
	@ cd fedora && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    fedora.json

fedora-test:
	@ cd test && \
	  ./run.sh \
	    --aws $(path)/aws.json \
	    --google $(path)/google.json \
	    --account $(path)/account.json \
	    --manifest $(path)/fedora/manifest.json \
	    --tests $(path)/fedora/tests.json

ubuntu:
	@ cd ubuntu && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    ubuntu.json

ubuntu-test:
	@ cd test && \
	  ./run.sh \
	    --aws $(path)/aws.json \
	    --google $(path)/google.json \
	    --account $(path)/account.json \
	    --manifest $(path)/ubuntu/manifest.json \
	    --tests $(path)/ubuntu/tests.json


.PHONY: clean
.PHONY: centos centos-test
.PHONY: debian debian-test
.PHONY: fedora fedora-test
.PHONY: ubuntu ubuntu-test
