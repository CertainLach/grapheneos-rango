#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

BUILD_NUMBER_LAST=$(cat ".buildnumbers/kernel" 2>/dev/null || echo 0)
export BUILD_NUMBER=$((BUILD_NUMBER_LAST + 1))
echo "$BUILD_NUMBER" >".buildnumbers/kernel"

pushd "$EXTRAS/KernelSU-Next"
{

	# I haven't debugged why their git code doesn't work with kleaf.
	# Doesn't matter, this thing ensures the values are correct before building the kernel.
	KSU_GIT_VERSION=$(git rev-list --count HEAD)

	START="# PROVIDED VERSION START"
	END="# PROVIDED VERSION END"
	sed -i "/${START}/,/${END}/d" kernel/Kbuild
	{
		echo "$START"
		echo "KSU_GIT_VERSION := $KSU_GIT_VERSION"
		echo "KSU_GIT_TAG := builtin"
		echo "KSU_GIT_VERSION_VALID := 1"
		echo "$END"
		cat "kernel/Kbuild"
	} >kernel/Kbuild.tmp
	mv kernel/Kbuild.tmp kernel/Kbuild
}
popd

apply_patches kernel
apply_patches kernel/aosp

pushd kernel
{
	rm -rf out

	pushd aosp
	{

		ln -sf "$EXTRAS/KernelSU-Next" ./
		ln -sf "$EXTRAS/susfs4ksu" ./

	}
	popd

	KLEAF_REPO_MANIFEST=aosp_manifest.xml "./build_$DEVICE.sh" --lto=full

}
popd
