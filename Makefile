platforms := aws,google

path := $(shell pwd)
version := $(shell grep -oe '\d\.\d\.\d' VERSION)
build := $(shell date -u +%Y%m%d-%H%M%S)


centos:
	@ cd centos && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    centos.json

debian:
	@ cd debian && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    debian.json

ubuntu:
	@ cd ubuntu && \
	  packer build -force \
	    -only '$(platforms)' \
	    -var 'version=$(version)' \
	    -var 'build=$(build)' \
	    -var-file '../aws.json' \
	    -var-file '../google.json' \
	    ubuntu.json


.PHONY: centos debian ubuntu
