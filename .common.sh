export OS_VER=16-qpr2
export DEVICE=rango
export KERNEL_VER=6.6
export BASEDIR="$PWD"
export PATCHES=$PWD/patches
export EXTRAS=$PWD/extras

apply_patches() {
	local repo_path="$1"
	local patch_dir="$BASEDIR/patches/$repo_path"

	pushd "$repo_path" || exit 1
	{
		test -d .git || test -f .git

		git reset --hard graphene-base
		git clean -fd

		for patch in "$patch_dir"/*.patch; do
			if [ -f "$patch" ]; then
				echo "Applying patch: $(basename "$patch")"
				git am -3 "$patch"
			fi
		done
	}
	popd || exit 1
}
