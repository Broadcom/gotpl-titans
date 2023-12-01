#!/bin/bash

# set -ex

currentPath=`pwd`
chartname="gotpl"

function buildBinaries {
    for GOOS in darwin linux; do
        for GOARCH in amd64; do
            mkdir -p bin/$GOOS-$GOARCH
            # CGO_ENABLED=0 is required for
            # https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
            GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED=0 go build -v -o bin/$GOOS-$GOARCH/$chartname
        done
    done
}

buildBinaries
