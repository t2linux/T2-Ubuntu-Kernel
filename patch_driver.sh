#!/bin/bash

set -eu -o pipefail

BUILD_PATH=/tmp/build-kernel

# Patches
APPLE_SMC_DRIVER_GIT_URL=https://github.com/AdityaGarg8/linux-t2-patches.git
APPLE_SMC_DRIVER_BRANCH_NAME=main
APPLE_SMC_DRIVER_COMMIT_HASH=1137ce0eff9435dbea25ceb74cf2ff1b9de942d9

rm -rf "${BUILD_PATH}"
mkdir -p "${BUILD_PATH}"
cd "${BUILD_PATH}" || exit

### AppleSMC and BT aunali fixes
git clone --single-branch --branch ${APPLE_SMC_DRIVER_BRANCH_NAME} ${APPLE_SMC_DRIVER_GIT_URL} \
  "${BUILD_PATH}/linux-mbp-arch"
cd "${BUILD_PATH}/linux-mbp-arch" || exit
git checkout ${APPLE_SMC_DRIVER_COMMIT_HASH}
rm 100*

while IFS= read -r file; do
  echo "==> Adding ${file}"
  cp -rfv "${file}" "${WORKING_PATH}"/patches/"${file##*/}"
done < <(find "${BUILD_PATH}/linux-mbp-arch" -type f -name "*.patch" | grep -vE '000[0-9]')
