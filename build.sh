#!/bin/bash

set -eu -o pipefail

USE_T2LINUX_REPO=false
if [[ ($USE_T2LINUX_REPO != true) && ($USE_T2LINUX_REPO != false) ]]
then
echo "Abort!"
exit 1
fi

KERNEL_VERSION=5.15.69
PKGREL=2

if [[ $USE_T2LINUX_REPO = true ]]
then
KERNEL_REPOSITORY=https://github.com/t2linux/kernel.git
else
#KERNEL_REPOSITORY=git://kernel.ubuntu.com/virgin/linux-stable.git
KERNEL_REPOSITORY=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
fi

APPLE_BCE_REPOSITORY=https://github.com/kekrby/apple-bce.git
APPLE_IBRIDGE_REPOSITORY=https://github.com/Redecorating/apple-ib-drv.git
REPO_PATH=$(pwd)
WORKING_PATH=/root/work
KERNEL_PATH="${WORKING_PATH}/linux-kernel"

## Debug commands
echo "Kernel version: ${KERNEL_VERSION}"
echo "Working path: ${WORKING_PATH}"
echo "Kernel repository: ${KERNEL_REPOSITORY}"
echo "Current path: ${REPO_PATH}"
echo "CPU threads: $(nproc --all)"
grep 'model name' /proc/cpuinfo | uniq

get_next_version () {
  echo $PKGREL
}

## Clean up
rm -rfv ./*.deb

mkdir "${WORKING_PATH}" && cd "${WORKING_PATH}"
cp -rf "${REPO_PATH}"/{patches,templates} "${WORKING_PATH}"
rm -rf "${KERNEL_PATH}"

### Dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y build-essential fakeroot libncurses-dev bison flex libssl-dev libelf-dev \
  openssl dkms libudev-dev libpci-dev libiberty-dev autoconf wget xz-utils git \
  libcap-dev bc rsync cpio dh-modaliases debhelper kernel-wedge curl gawk dwarves zstd

### get Kernel and Drivers
if [[ $USE_T2LINUX_REPO = true ]]
then
git clone --depth 1 --single-branch --branch "t2-v${KERNEL_VERSION}" \
  "${KERNEL_REPOSITORY}" "${KERNEL_PATH}"
else
git clone --depth 1 --single-branch --branch "v${KERNEL_VERSION}" \
  "${KERNEL_REPOSITORY}" "${KERNEL_PATH}"
fi
git clone --depth 1 "${APPLE_BCE_REPOSITORY}" "${KERNEL_PATH}/drivers/staging/apple-bce"
git clone --depth 1 "${APPLE_IBRIDGE_REPOSITORY}" "${KERNEL_PATH}/drivers/staging/apple-ibridge"
cd "${KERNEL_PATH}" || exit

if [[ $USE_T2LINUX_REPO = false ]]
then
#### Create patch file with custom drivers
echo >&2 "===]> Info: Creating patch file... "
KERNEL_VERSION="${KERNEL_VERSION}" WORKING_PATH="${WORKING_PATH}" "${REPO_PATH}/patch_driver.sh"
fi

#### Apply patches
cd "${KERNEL_PATH}" || exit

echo >&2 "===]> Info: Applying patches... "
[ ! -d "${WORKING_PATH}/patches" ] && {
  echo 'Patches directory not found!'
  exit 1
}


while IFS= read -r file; do
  echo "==> Adding $file"
  patch -p1 <"$file"
done < <(find "${WORKING_PATH}/patches" -type f -name "*.patch" | sort)

#chmod a+x "${KERNEL_PATH}"/debian/rules
#chmod a+x "${KERNEL_PATH}"/debian/scripts/*
#chmod a+x "${KERNEL_PATH}"/debian/scripts/misc/*

echo >&2 "===]> Info: Bulding src... "

cd "${KERNEL_PATH}"
make clean

# Make config friendly with vanilla kernel
sed -i 's/CONFIG_VERSION_SIGNATURE=.*/CONFIG_VERSION_SIGNATURE=""/g' "${WORKING_PATH}/templates/default-config"
sed -i 's/CONFIG_SYSTEM_TRUSTED_KEYS=.*/CONFIG_SYSTEM_TRUSTED_KEYS=""/g' "${WORKING_PATH}/templates/default-config"
sed -i 's/CONFIG_SYSTEM_REVOCATION_KEYS=.*/CONFIG_SYSTEM_REVOCATION_KEYS=""/g' "${WORKING_PATH}/templates/default-config"
sed -i 's/CONFIG_DEBUG_INFO=y/# CONFIG_DEBUG_INFO is not set/g' "${WORKING_PATH}/templates/default-config"

# I want silent boot
sed -i 's/CONFIG_CONSOLE_LOGLEVEL_DEFAULT=.*/CONFIG_CONSOLE_LOGLEVEL_DEFAULT=4/g' "${WORKING_PATH}/templates/default-config"
sed -i 's/CONFIG_CONSOLE_LOGLEVEL_QUIET=.*/CONFIG_CONSOLE_LOGLEVEL_QUIET=1/g' "${WORKING_PATH}/templates/default-config"
sed -i 's/CONFIG_MESSAGE_LOGLEVEL_DEFAULT=.*/CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4/g' "${WORKING_PATH}/templates/default-config"

# Copy the modified config
cp "${WORKING_PATH}/templates/default-config" "${KERNEL_PATH}/.config"
make olddefconfig
#./scripts/config --module CONFIG_BT_HCIBCM4377

# Get rid of the dirty tag
echo "" >"${KERNEL_PATH}"/.scmversion

# Build Deb packages
make -j "$(getconf _NPROCESSORS_ONLN)" deb-pkg LOCALVERSION=-t2 KDEB_PKGVERSION="$(make kernelversion)-$(get_next_version)"

#### Copy artifacts to shared volume
echo >&2 "===]> Info: Copying debs and calculating SHA256 ... "
#cp -rfv ../*.deb "${REPO_PATH}/"
#cp -rfv "${KERNEL_PATH}/.config" "${REPO_PATH}/kernel_config_${KERNEL_VERSION}"
cp -rfv "${KERNEL_PATH}/.config" "/tmp/artifacts/kernel_config_${KERNEL_VERSION}"
cp -rfv ../*.deb /tmp/artifacts/
sha256sum ../*.deb >/tmp/artifacts/sha256
