#!/bin/bash

# Copyright 2017-2020 Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

docker buildx build -t docker.io/errordeveloper/qemu-go-test .

# <3 https://remy.io/blog/custom-built-kernel-running-go-binary/
mkdir -p initramfs
cd initramfs
#GOOS=linux GOARCH=amd64 go build -o init ..
GOOS=linux GOARCH=amd64 go test -c -o init ..
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..

docker run -ti --volume "$(pwd):/mnt" docker.io/errordeveloper/qemu-go-test

