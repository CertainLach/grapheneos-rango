#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

mkdir -p os-$OS_VER

pushd os-$OS_VER
{

	# TODO: Also support for stable releases with signature verification

	repo init -u https://github.com/GrapheneOS/platform_manifest.git -b $OS_VER
	repo forall -vc "git reset --hard"
	repo sync -j8 --force-sync

	set +u
	source ./build/envsetup.sh
	set -u

	yarn --cwd vendor/adevtool/ install --force
	vendor/adevtool/bin/run generate-all -d $DEVICE

}
popd
