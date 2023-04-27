#!/bin/bash

docker pull ubuntu
docker tag ubuntu hip-mne/nc-webdav:latest
docker build -t hip-mne \
	--build-arg CI_REGISTRY_IMAGE=hip-mne \
	--build-arg DAVFS2_VERSION=latest \
	--build-arg CI_REGISTRY=toto \
	.
	
docker build -t hip-mne-test -f fakeuser.Dockerfile .
