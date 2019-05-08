#!/bin/bash

# This script will build a Live Fedora 27 Workstation ISO image that will
# boot on a MacbookPro14,1
#
# It uses some kickstart files, some patches, drivers, the rawhide kernel and
# a few other tricks.
#
# Written by Mark Knowles <mark@mknowles.com.au>
# Please note that this script is not officially affiliated with Red Hat or
# Fedora despite my employment with Red Hat. This is a personal project
# conducted in personal time.


# Where to find the kickstarts
SPINS_DIR=/usr/share/spin-kickstarts

# The kickstarts we need to build the Live ISO
KS[0]=fedora-live-base.ks
KS[1]=fedora-live-workstation.ks
KS[2]=fedora-repo.ks
KS[3]=fedora-repo-not-rawhide.ks
KS[4]=fedora-workstation-common.ks
KS[5]=fedora-live-mate_compiz.ks
KS[6]=fedora-mate-common.ks
KS[7]=fedora-live-minimization.ks

# The kickstart that we want to build with livecd-creator
#MAIN_KS=fedora-live-workstation.ks
MAIN_KS=fedora-live-mate_compiz.ks

# These are the packages we need to actually build the whole thing
BUILD_PKGS[0]=livecd-tools
BUILD_PKGS[1]=spin-kickstarts

PATCHES[0]=fedora-live-base.ks.patch

EXTRAS[0]=miniwebserver.py
EXTRAS[1]=61-evdev-local.hwdb

SCRIPT_DIR=(dirname "$0")

usage() {
    (echo "Usage: build_iso.sh [-s] [-c] build_dir"
    echo
    echo "Options"
    echo "  -s     Launch a shell when the build is halfway"
    echo "  -c     Use existing cache dir to prevent multiple downloads, if it exists") > /dev/stderr
    exit 1
}

while getopts ":sc" opt; do
    case $opt in
    s)
        SHELL_OPT="--shell"
        ;;
    c)
        CACHE_OPT="--cacheonly"
        ;;
    else)
        echo $opt
        ;;
    \?)
        usage
        ;;

    esac
done

shift "$((OPTIND-1))"

if [ "$#" -ne 1 ]; then
    usage
fi

BUILD_DIR="$1"
TMP_DIR="${BUILD_DIR}/tmp"
CACHE_DIR="${BUILD_DIR}/cache"
mkdir -p "${TMP_DIR}"

# remove cache if we've been told not to work from it
if [[ -z ${CACHE_OPT} ]]; then
    rm -fr ${CACHE_DIR}
fi

# make the cache directory if it doesn't exist
if [[ ! -d "${CACHE_DIR}" ]]; then
    mkdir -p "${CACHE_DIR}"

    # if the cache option has been specified, unset it
    if [[ ! -z "${CACHE_OPT}" ]]; then
        CACHE_OPT=""
    fi
fi

# Make sure the packages are installed first, if not prompt the user to install
# them
install_pkgs=()
for pkg in ${BUILD_PKGS[*]}; do

    if rpm -qi "${pkg}" > /dev/null; then
        echo "Package already installed: $pkg"
    else
        echo "Need to install package $pkg"
        install_pkgs+=($pkg)
    fi
done

if [ ! -z $install_pkgs ]; then
    echo "Going to install some packages for you"
    dnf install ${install_pkgs[@]}
fi

# copy the kickstarts to the build directory
for k in ${KS[*]}; do
    cp ${SPINS_DIR}/$k ${BUILD_DIR}
done

# copy our special sauce into the build dir
cp macbook.ks ${BUILD_DIR}

# patch the main kickstart with our special sauce
for p in ${PATCHES[*]}; do
    cp $p ${BUILD_DIR}
done

for e in ${EXTRAS[*]}; do
    cp $e ${BUILD_DIR}
done

# temporary repo server
echo Creating repo
createrepo repo

echo Starting dodgy web server
./miniwebserver.py &
WEBSERVER_PID=$!

cd ${BUILD_DIR}
# patch the main kickstart with our special sauce
for p in ${PATCHES[*]}; do
    patch -p1 < $p
done

set -x
livemedia-creator --make-disk --no-virt --ks ${MAIN_KS} --releasever=29 --fs-label=f29_mbp14bigpenis

# make the iso
#livecd-creator --verbose --config=${MAIN_KS} --fslabel=f29_mbp14 --releasever=29 --tmpdir=${TMP_DIR} --cache=${CACHE_DIR} -d -v --logfile=livecd_log.txt ${CACHE_OPT} ${SHELL_OPT}
#livecd-creator --verbose --config=${MAIN_KS} --fslabel=f29_mbp14 --releasever=29 --tmpdir=${TMP_DIR} --cache=${CACHE_DIR} -d -v --logfile=livecd_log.txt ${CACHE_OPT} ${SHELL_OPT}

echo Killing dodgy web server
kill -9 ${WEBSERVER_PID}

