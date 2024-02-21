#!/bin/bash

# set -ex

opt1=$1

currentPath=`pwd`
appname="gotpl"
imagename="ubi-podman-titan"
ver="4.8.1"

function buildBinaries {
    for GOOS in darwin linux; do
        for GOARCH in amd64; do
            mkdir -p bin/$GOOS-$GOARCH
            # CGO_ENABLED=0 is required for
            # https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
            GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED=0 go build -v -o bin/$GOOS-$GOARCH/$appname
        done
    done
}

function loginDocker {
  if [ -z "$HOME/.secrets/jfrog.token" ]; then
    echo "No $HOME/.secrets/jfrog.token is found, please put your jfrog identity token into this file."
    exit
  elif [ -z "$HOME/.secrets/jfrog.user" ]; then
    echo "No $HOME/.secrets/jfrog.user is found, please put your employ id into this file."
    exit
  else
    echo "Found jfrog.token and jfrog.user - continue"
    token=$(cat ~/.secrets/jfrog.token)
    user=$(cat ~/.secrets/jfrog.user)
    docker login -u $user -p $token sbo-sps-docker-release-local.usw1.packages.broadcom.com
    docker login -u $user -p $token sbo-saas-docker-release-local.usw1.packages.broadcom.com
  fi
}

function buildDocker {
  loginDocker
  docker build -t sbo-sps-docker-release-local.usw1.packages.broadcom.com/saas-devops/redhat/ubi/$imagename:$ver .
  if [ "$opt1" == "--deploy" ]
  then
    docker push sbo-sps-docker-release-local.usw1.packages.broadcom.com/saas-devops/redhat/ubi/$imagename:$ver
    docker tag sbo-sps-docker-release-local.usw1.packages.broadcom.com/saas-devops/redhat/ubi/$imagename:$ver gcr.io/saas-dev-sed-sharedicd-gke/gkesharedicd/saas-devops/redhat/ubi/$imagename:$ver
    docker push gcr.io/saas-dev-sed-sharedicd-gke/gkesharedicd/saas-devops/redhat/ubi/$imagename:$ver
  fi
}

buildBinaries
buildDocker

