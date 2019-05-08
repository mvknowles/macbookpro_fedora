#!/bin/bash

if [[ "$1" != "--force" ]]; then
    echo "Not quite working yet. Use --force to test/debug."
    exit 1
fi

WORKING=.
RPM_DIR="/home/mark/kernel/x86_64"
KERNEL_VER="4.19.15-301.mk_kernel"
APPLESPI_REPO="https://github.com/roadrunner2/macbook12-spi-driver.git"
APPLESPI_VER="0.1"
KEEP_WORKING=1

WORKING=$(mktemp -d || exit $?)

cleanup() {
    [[ ${KEEP_WORKING} ]] && echo "Working: ${WORKING}"|| rm -fr "$WORKING"
}

freak() {
    z=$?
    ( [[ -z $1 ]] && echo Failed || echo $1) >&2
    cleanup
    exit $z
}

#/kernel-devel-4.19.15-301.mk_kernel.fc29.x86_64.rpm"

cd ${WORKING}

# clone the source for the applespi driver
git clone ${APPLESPI_REPO} "applespi-${APPLESPI_VER}" || freak

# extract the kernel headers from kernel-devel
mkdir kernel_headers
cd kernel_headers
HRPM="${RPM_DIR}/kernel-devel-${KERNEL_VER}.fc29.x86_64.rpm"

[[ -e $HRPM ]] || freak "Couldn't find kernel header rpm ${HRPM}"

echo "Extracting ${HRPM} to get kernel headers"
rpm2cpio ${HRPM}| cpio -idm
cd ..
KSOURCE="${WORKING}/kernel_headers/usr/src/kernels/${KERNEL_VER}.fc29.x86_64"
[[ -e ${KSOURCE} ]] || freak "No kernel headers found at ${KERNEL_VER}"
echo "Kernel headers: ${KSOURCE}"

set -x
dkms build applespi -v ${APPLESPI_VER} --sourcetree "${WORKING}" --dkmstree "${WORKING}/applespi-0.1" --kernelsourcedir ${KSOURCE} || freak

cleanup
