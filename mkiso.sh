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


DEFAULT_KICKSTART="macbook14-fedora-live.ks"

# Where to find the kickstarts
SPINS_DIR=/usr/share/spin-kickstarts

# These are the packages we need to actually build the whole thing
BUILD_PKGS[0]=livecd-tools
BUILD_PKGS[1]=spin-kickstarts

#PATCHES[0]=fedora-live-base.ks.patch
#PATCHES[0]=fedora-live-minimization.ks.patch

KS[0]=fedora-live-base.ks
KS[1]=fedora-live-workstation.ks
KS[2]=fedora-repo.ks
KS[3]=fedora-repo-not-rawhide.ks
KS[4]=fedora-workstation-common.ks
KS[5]=fedora-live-mate_compiz.ks
KS[6]=fedora-mate-common.ks
KS[7]=fedora-live-minimization.ks

remix_kickstarts=(./kickstarts/*/*.ks)
remix_kickstarts+=(./kickstarts/*.ks)

EXTRA_FILES=("61-evdev-local.hwdb")

usage() {
    (echo "Usage: build_iso.sh [-s] [-c] [-a] [-k kickstart_file] build_dir"
    echo
    echo "Options"
    echo "  -k     Choose a kickstart"
    echo "  -s     Launch a shell when the build is halfway"
    echo "  -c     Use existing cache dir to prevent multiple downloads, if it exists") > /dev/stderr
}

remix_kickstart="${DEFAULT_KICKSTART}"
while getopts ":schk:" opt; do
    case $opt in
    s)
        SHELL_OPT="--shell"
        ;;
    c)
        CACHE_OPT="--cacheonly"
        ;;
    k)
        remix_kickstart=$(basename "${OPTARG}")
        ;;
    h)
        usage
        exit 0
        ;;
    else)
        usage
        exit 1
        ;;

    esac
done

echo remixks ${remix_kickstart}

shift "$((OPTIND-1))"

if [ "$#" -ne 1 ]; then
    usage
    exit 1
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
    echo "I will install some packages for you"
    echo "You will be asked for permission:"
    echo
    echo
    dnf install ${install_pkgs[@]}
fi

# copy all the template spins to our build dir
for ks in ${KS[*]}; do
    echo ks $ks
    cp ${SPINS_DIR}/${ks} ${BUILD_DIR}
done

# copy in our kickstarts, flattening the file structure
for ks in ${remix_kickstarts[*]}; do
    echo ks $ks
    cp "$ks" "${BUILD_DIR}"
done

# temporary repo server
echo Creating repo
rm -fr repo/.repodata
createrepo repo

echo Starting dodgy web server
./miniwebserver.py &
WEBSERVER_PID=$!

########
#Build
########


cd ${BUILD_DIR}
# patch the main kickstart with our special sauce
#for p in ${PATCHES[*]}; do
#    patch -p1 < $p
#done


# bake a fresh iso
rm -f livecd_log.txt
livecd-creator --config="${remix_kickstart}" --fslabel=fc29_mbp14 --releasever=29 --tmpdir=${TMP_DIR} --cache=${CACHE_DIR} -d -v --logfile=livecd_log.txt ${CACHE_OPT} ${SHELL_OPT}

echo Killing dodgy web server
kill -9 ${WEBSERVER_PID}

#livemedia-creator --make-disk --no-virt --ks  --tmp=/mnt/livecdcreator/tmp --result-dir /mnt/livec --releasever=25 
