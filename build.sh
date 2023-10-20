#!/bin/bash

set -eu -o pipefail

KERNEL_REL=6.5.0
UBUNTU_REL=10.10
PKGREL=1
KERNEL_BRANCH="Ubuntu-${KERNEL_REL}-${UBUNTU_REL}"
KERNEL_VERSION="${KERNEL_REL}-${UBUNTU_REL}-generic"
KERNEL_REPOSITORY=git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/mantic
REPO_PATH=$(pwd)
WORKING_PATH=/root/work
KERNEL_PATH="${WORKING_PATH}/linux-kernel"

### Debug commands
echo "KERNEL_VERSION=$KERNEL_VERSION"
echo "${WORKING_PATH}"
echo "Current path: ${REPO_PATH}"
echo "CPU threads: $(nproc --all)"
grep 'model name' /proc/cpuinfo | uniq

get_next_version () {
  echo $PKGREL
}

### Clean up
rm -rfv ./*.deb

mkdir "${WORKING_PATH}" && cd "${WORKING_PATH}"
cp -rf "${REPO_PATH}"/{patches,templates} "${WORKING_PATH}"
rm -rf "${KERNEL_PATH}"

### Dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y build-essential fakeroot libncurses-dev bison flex libssl-dev libelf-dev \
  openssl dkms libudev-dev libpci-dev libiberty-dev autoconf wget xz-utils git \
  libcap-dev bc rsync cpio dh-modaliases debhelper kernel-wedge curl gawk dwarves llvm zstd \
  rust-1.62-all rust-1.62-src bindgen-0.56 default-jdk liblzma-dev libzstd-dev libdw-dev \
  systemtap-sdt-dev libunwind-dev libslang2-dev libnuma-dev libbabeltrace-dev libtraceevent-dev

### get Kernel
git clone --depth 1 --single-branch --branch "${KERNEL_BRANCH}" \
  "${KERNEL_REPOSITORY}" "${KERNEL_PATH}"
cd "${KERNEL_PATH}" || exit

#### Create patch file with custom drivers
#echo >&2 "===]> Info: Creating patch file... "
#KERNEL_VERSION="${KERNEL_VERSION}" WORKING_PATH="${WORKING_PATH}" "${REPO_PATH}/patch_driver.sh"

#### Apply patches
cd "${KERNEL_PATH}" || exit

echo >&2 "===]> Info: Applying patches... "
rm -rf ${WORKING_PATH}/patches/200* # Probbaly will mess up iGPU switch!

[ ! -d "${WORKING_PATH}/patches" ] && {
  echo 'Patches directory not found!'
  exit 1
}


while IFS= read -r file; do
  echo "==> Adding $file"
  patch -p1 <"$file"
done < <(find "${WORKING_PATH}/patches" -type f -name "*.patch" | sort)

chmod a+x "${KERNEL_PATH}"/debian/rules
chmod a+x "${KERNEL_PATH}"/debian/scripts/*
chmod a+x "${KERNEL_PATH}"/debian/scripts/misc/*

echo >&2 "===]> Info: Bulding src... "

cd "${KERNEL_PATH}"

# Build Deb packages
sed -i "s/${KERNEL_REL}-${UBUNTU_REL}/${KERNEL_REL}-${UBUNTU_REL}+t2/g" debian.master/changelog
LANG=C fakeroot debian/rules clean
LANG=C fakeroot debian/rules binary-headers binary-generic binary-perarch

#### Copy artifacts to shared volume
echo >&2 "===]> Info: Copying debs and calculating SHA256 ... "
#cp -rfv ../*.deb "${REPO_PATH}/"
#cp -rfv "${KERNEL_PATH}/.config" "${REPO_PATH}/kernel_config_${KERNEL_VERSION}"
cp -rfv "${KERNEL_PATH}/debian/build/build-generic/.config" "/tmp/artifacts/kernel_config_${KERNEL_VERSION}"
cp -rfv ../*.deb /tmp/artifacts/
sha256sum ../*.deb >/tmp/artifacts/sha256
