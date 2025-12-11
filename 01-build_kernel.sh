#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

BUILD_NUMBER_LAST=$(cat ".buildnumbers/kernel" 2>/dev/null || echo 0)
export BUILD_NUMBER=$((BUILD_NUMBER_LAST + 1))
echo "$BUILD_NUMBER" >".buildnumbers/kernel"

PATCHES=$PWD/patches
EXTRAS=$PWD/extras

pushd kernel

git reset --hard
git apply "$PATCHES/kernel/"*.patch

pushd aosp

git reset --hard
git apply "$PATCHES/kernel/aosp/"*.patch
ln -sf "$EXTRAS/KernelSU-Next" ./
ln -sf "$EXTRAS/susfs4ksu" ./

popd


KSU_REVCOUNT=$(cd aosp/KernelSU-Next && git rev-list --count HEAD)
[ "${KSU_REVCOUNT}" -ne 0 ] || echo "KernelSU-Next clone is broken, unable to get rev-list"
sed -i "s/^KSU_GIT_VERSION := .*/KSU_GIT_VERSION := $KSU_REVCOUNT/" aosp/KernelSU-Next/kernel/Makefile

BUILD_AOSP_KERNEL=1 KLEAF_REPO_MANIFEST=aosp_manifest.xml "./build_$DEVICE.sh" --lto=full --repo_manifest="$PWD:$PWD/aosp_manifest.xml"
