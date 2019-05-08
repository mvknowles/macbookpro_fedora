
zerombr
clearpart --all
part / --size=12000 --fstype ext4

rootpw --plaintext macbook
user --name=mark --groups=wheel --plaintext --password=macbook 

repo --name=mk_kernel --baseurl=http://localhost:8000/repo

%packages
# mark's picks
@mate

# minimal
kernel-devel
kmod
dkms
git
gcc
make
automake
gcc-c++
%end

%post
cat <<EOF | sudo tee /etc/dracut.conf.d/00-macbook.conf
# load all drivers needed for the keyboard+touchpad
add_drivers+="applespi intel_lpss_pci spi_pxa2xx_platform appletb"
EOF

cat <<EOF | sudo tee /etc/modules-load.d/apple.conf
applespi
EOF

%end

%post --nochroot
set -x

mkdir -p $INSTALL_ROOT/etc/udev/hwdb.d
cat <<EOF | sudo tee /etc/udev/hwdb.d/61-evdev-local.hwdb
# MacBook8,1 (2015), MacBook9,1 (2016), MacBook10,1 (2017)
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBook8,1:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBook9,1:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBook10,1:*
 EVDEV_ABS_00=::95
 EVDEV_ABS_01=::90
 EVDEV_ABS_35=::95
 EVDEV_ABS_36=::90

# MacBookPro13,* (Late 2016), MacBookPro14,* (Mid 2017)
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro13,1:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro13,2:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro14,1:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro14,2:*
 EVDEV_ABS_00=::96
 EVDEV_ABS_01=::94
 EVDEV_ABS_35=::96
 EVDEV_ABS_36=::94

evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro13,3:*
evdev:name:Apple SPI Touchpad:dmi:*:svnAppleInc.:pnMacBookPro14,3:*
 EVDEV_ABS_00=::96
 EVDEV_ABS_01=::95
 EVDEV_ABS_35=::96
 EVDEV_ABS_36=::95
EOF
%end

%post
set -x
# figure out what rawhide kernel version we're running
RAWHIDE_VER=$(/usr/bin/rpm -qa | /usr/bin/sed -n  's/kernel-core-\(.*mk_kernel.*\)/\1/p')
echo "${RAWHIDE_VER}" > /dev/shm/rawhide_ver
echo "Rawhide version: ${RAWHIDE_VER}"

echo nameserver 8.8.8.8 > /etc/resolv.conf
git clone "https://github.com/roadrunner2/macbook12-spi-driver.git" /usr/src/applespi-0.1
# make/gcc doesn't work without a proper path
OLDPATH=$PATH
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:$PATH
/usr/sbin/dkms install -m applespi -v 0.1 -k ${RAWHIDE_VER} --no-prepare-kernel
export PATH=$OLDPATH

/usr/sbin/depmod -a ${RAWHIDE_VER}

# for some strange reason, /etc/dracut.conf.d/* isn't being picked up when
# using --kver, so we force the drivers into the initramfs
/usr/bin/dracut -v --force --kver ${RAWHIDE_VER} --force-drivers "applespi intel_lpss_pci spi_pxa2xx_platform appletb"
%end

%post --nochroot
set -x
RAWHIDE_VER=$(cat /dev/shm/rawhide_ver)

# this seems like an odd thing to do, but it's not. the problem is that
# if you regenerate the initramfs, your initrd won't get updated
cp $INSTALL_ROOT/boot/initramfs-*mk_kernel*.img $LIVE_ROOT/isolinux/initrd0.img
%end

