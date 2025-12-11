#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

mkdir -p .buildnumbers

BUILD_DATETIME=$(date -u +%s)
BUILD_NUMBER_PARTIAL=$(date -u -d "@$BUILD_DATETIME" +%Y%m%d)
INC_NUMBER_LAST=$(cat ".buildnumbers/os-last-$BUILD_NUMBER_PARTIAL" 2>/dev/null || echo 0)
INC_NUMBER=$(printf "%02d" $((INC_NUMBER_LAST + 1)))
echo "$INC_NUMBER" >".buildnumbers/os-last-$BUILD_NUMBER_PARTIAL"

BUILD_NUMBER=${BUILD_NUMBER_PARTIAL}$INC_NUMBER

mkdir -p kernel

mkdir -p os-$OS_VER

pushd os-$OS_VER
echo "Cleaning out directory for the new release"
rm -rf out/
echo "Writing new version numbers"
mkdir -p out/soong
echo "$BUILD_DATETIME" >out/build_date.txt
echo "$BUILD_NUMBER" >out/soong/build_number.txt
popd
