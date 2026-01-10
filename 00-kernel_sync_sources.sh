#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

mkdir -p kernel

pushd kernel
{

	if ! test -d .git; then
		git clone https://gitlab.com/grapheneos/kernel_pixel_muzel.git .
	fi
	git fetch
	git reset --hard "origin/$OS_VER"
	git submodule deinit -f .
	git submodule update --init

	git tag --no-sign -f graphene-base
	pushd aosp
	{

		git tag --no-sign -f graphene-base

	}
	popd

}
popd
