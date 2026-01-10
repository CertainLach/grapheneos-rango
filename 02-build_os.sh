#!/usr/bin/env -S distrobox enter grapheneos-arch -- bash

set -eux

source .common.sh

echo "Applying OS patches"
apply_patches os/frameworks/base
apply_patches os/build/soong

pushd os
{

	echo "Configuring OTA"
	xmlstarlet ed -L \
		-u '//string[@name="url"]' \
		-v 'https://graphene.delta.rocks/' \
		packages/apps/Updater/res/values/config.xml
	export OFFICIAL_BUILD=true

	echo "Ensuring keys/releases are preserved between rebuilds (Those directories are stored outside of the VM)"
	ln -sf ../keys ../releases ./

	echo "Reset kernel"
	pushd ./device/google/laguna-kernels/$KERNEL_VER
	{
		git reset --hard graphene-base
		git clean -fd
		rsync "$BASEDIR/kernel/out/$DEVICE/dist/" "./grapheneos/$DEVICE/" -arv --delete
	}
	popd

	echo "Setting up env"
	set +u
	source ./build/envsetup.sh
	lunch "$DEVICE-cur-user"
	set -u

	echo "Building target"
	m vendorbootimage vendorkernelbootimage target-files-package

	echo "Making otatools"
	m otatools-package

	echo "Finalizing"
	script/finalize.sh

	echo "Generating release"
	"$BASEDIR/.with-passphrase.exp" script/generate-release.sh $DEVICE "$BUILD_NUMBER"

	# Incremental updates are published before the original to ensure that they are used instead of the full
	if test -f ../.buildnumbers/os-$OS_VER-$DEVICE; then
		echo "Generating incremental update"
		PREV_BUILD_NUMBER=$(cat ../.buildnumbers/os-$OS_VER-$DEVICE)
		# "$BASEDIR/.with-passphrase.exp" script/generate-delta.sh $DEVICE "$PREV_BUILD_NUMBER" "$BUILD_NUMBER"
		#
		# echo "Publishing incremental update"
		#
		# pushd "releases/$BUILD_NUMBER/"
		# {
		#
		# 	rsync -rv "$DEVICE-incremental-$PREV_BUILD_NUMBER-$BUILD_NUMBER.zip" karma:/var/lib/graphene-updates/
		#
		# }
		# popd
	fi

	pushd "releases/$BUILD_NUMBER/release-$DEVICE-$BUILD_NUMBER/"
	{

		rsync --exclude $DEVICE'-factory-*.zip' --exclude $DEVICE'-img-*.zip' --exclude $DEVICE'-install-*.zip' --exclude $DEVICE'-target_files.zip' -rv ./ karma:/var/lib/graphene-updates/

	}
	popd

}
popd

echo "$BUILD_NUMBER" >.buildnumbers/os-$OS_VER-$DEVICE
