rel=noble

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
# Some parts of script taken from imagebuilder repo by hexdump0815
export DEBIAN_FRONTEND=noninteractive

export LANG=C

POSSIBLE_TARGET_HOST="aarch64"
read -p "Choose platform (mt8183/mt8173): " mtk
if [[ "$mtk" != "mt8183" && "$mtk" != "mt8173" ]]; then
    echo "Invalid platform... exiting"
    exit 1
fi

cd `dirname $0`/..
export WORKDIR=`pwd`
mkdir cache
mkdir download
mkdir root
export BUILD_ROOT=root/
export BUILD_ROOT_CACHE=cache/
export DOWNLOAD_DIR=download/
apt install binfmt-support qemu-user-binfmt qemu-user-static -y
systemctl start binfmt-support.service
if [ -d ${BUILD_ROOT} ]; then
  echo ""
  echo "build root ${BUILD_ROOT} already exists - giving up for safety reasons ..."
  echo ""
  exit 1
fi

if [[ "$mtk" == "mt8183" ]]; then
    wget https://github.com/velvet-os/imagebuilder/raw/refs/heads/main/systems/chromebook_kukui/partition-mapping.txt
    source partition-mapping.txt
fi 

if [[ "$mtk" == "mt8173" ]]; then
    wget https://github.com/velvet-os/imagebuilder/raw/refs/heads/main/systems/chromebook_oak/partition-mapping.txt
    source partition-mapping.txt
fi 

DEFAULT_USERNAME=unity
root=LABEL=unityroot


BOOTSTRAP_ARCH="arm64"
SERVER_PREFIX="ports."
SERVER_POSTFIX=""
LANG=C debootstrap --variant=minbase --arch=${BOOTSTRAP_ARCH} ${2} ${BUILD_ROOT_CACHE} http://${SERVER_PREFIX}ubuntu.com/${SERVER_POSTFIX}
echo "deb http://ports.ubuntu.com/ubuntu-ports/ $rel-security restricted multiverse main universe" | tee cache/etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ubuntu-ports/ $rel-updates restricted multiverse main universe" | tee -a cache/etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ubuntu-ports/ $rel-backports restricted multiverse main universe" | tee -a cache/etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ubuntu-ports/ $rel main universe restricted multiverse" | tee -a cache/etc/apt/sources.list
mount -o bind /dev ${BUILD_ROOT_CACHE}/dev
mount -o bind /dev/pts ${BUILD_ROOT_CACHE}/dev/pts
mount -t sysfs /sys ${BUILD_ROOT_CACHE}/sys
mount -t proc /proc ${BUILD_ROOT_CACHE}/proc
cp /etc/resolv.conf ${BUILD_ROOT_CACHE}/etc/resolv.conf
cp /proc/mounts ${BUILD_ROOT_CACHE}/etc/mtab
echo "apt-get -yq install locales vim openssh-server ssh-askpass sudo net-tools ifupdown iputils-ping kmod less rsync u-boot-tools usbutils dosfstools mesa-utils mesa-utils-extra console-data xubuntu-desktop linux-firmware lvm2 cryptsetup-bin cryptsetup-initramfs slick-greeter rsyslog btrfs-progs btrfs-compsize dialog cgpt lz4 vboot-kernel-utils plymouth plymouth-label plymouth-theme-xubuntu-logo plymouth-theme-xubuntu-text xserver-xorg-video-fbdev xinput rfkill curl gnome-system-tools gnome-system-monitor iptables firmware-sof-signed git strace glmark2 pwgen fdisk gdisk libglib2.0-bin initramfs-tools network-manager && apt update && apt upgrade -y" | tee cache/post.sh
chroot ${BUILD_ROOT_CACHE} /post.sh
rm -rf ${BUILD_ROOT_CACHE}/post.sh
umount ${BUILD_ROOT_CACHE}/proc ${BUILD_ROOT_CACHE}/sys ${BUILD_ROOT_CACHE}/dev/pts ${BUILD_ROOT_CACHE}/dev
echo "copying over the root cache to the target root - this may take a while ..."
date
rsync -axADHSX --no-inc-recursive ${BUILD_ROOT_CACHE}/ ${BUILD_ROOT}
date
echo "done"
echo ""
mount -o bind /dev ${BUILD_ROOT}/dev
mount -o bind /dev/pts ${BUILD_ROOT}/dev/pts
mount -t sysfs /sys ${BUILD_ROOT}/sys
mount -t proc /proc ${BUILD_ROOT}/proc

# do this to avoid failing apt installs due to a too old fs-cache
chroot ${BUILD_ROOT} apt-get update

echo "systemctl disable fwupd.service && systemctl disable fwupd-refresh.service && systemctl disable apt-daily && systemctl disable apt-daily-upgrade && systemctl disable apt-daily-upgrade.timer && systemctl disable unattended-upgrades.service && sed -i 's,Update-Package-Lists "1",Update-Package-Lists "0",g' /etc/apt/apt.conf.d/10periodic && sed -i 's,Update-Package-Lists "1",Update-Package-Lists "0",g;s,Unattended-Upgrade "1",Unattended-Upgrade "0",g' /etc/apt/apt.conf.d/20auto-upgrades && useradd -c unity -d /home/unity -m -s /bin/bash unity && echo "unity:ubuntu" | sudo chpasswd && usermod -a -G sudo unity && usermod -a -G audio unity && usermod -a -G video unity && usermod -a -G render unity && apt-get -yq remove snapd dmidecode && apt-get -yq auto-remove" | tee root/post2.sh
chroot ${BUILD_ROOT} /post2.sh
cd ${BUILD_ROOT}/
rm -rf post2.sh
wget https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.12.28-stb-cbm%2B/6.12.28-stb-cbm+.tar.gz
tar -xvf 6.12.28-stb-cbm+.tar.gz

if [ -f ${WORKDIR}/systems/${1}/rc-local-additions.txt ]; then
  echo "" >> etc/rc.local
  echo "# additions for ${1}" >> etc/rc.local
  echo "" >> etc/rc.local
  cat ${WORKDIR}/systems/${1}/rc-local-additions.txt >> etc/rc.local
fi
if [ -f ${WORKDIR}/systems/${1}/rc-local-additions-${3}.txt ]; then
  echo "" >> etc/rc.local
  echo "# additions for ${1} ${3}" >> etc/rc.local
  echo "" >> etc/rc.local
  cat ${WORKDIR}/systems/${1}/rc-local-additions-${3}.txt >> etc/rc.local
fi
echo "" >> etc/rc.local
echo "exit 0" >> etc/rc.local

# adjust some config files if they exist
if [ -f etc/modules-load.d/cups-filters.conf ]; then
  sed -i 's,^lp,#lp,g' etc/modules-load.d/cups-filters.conf
  sed -i 's,^ppdev,#ppdev,g' etc/modules-load.d/cups-filters.conf
  sed -i 's,^parport_pc,#parport_pc,g' etc/modules-load.d/cups-filters.conf
fi
if [ -f etc/NetworkManager/NetworkManager.conf ]; then
  sed -i 's,^managed=false,managed=true,g' etc/NetworkManager/NetworkManager.conf
  touch etc/NetworkManager/conf.d/10-globally-managed-devices.conf
fi
if [ -f etc/default/numlockx ]; then
  sed -i 's,^NUMLOCK=auto,NUMLOCK=off,g' etc/default/numlockx
fi
if [ -f etc/default/apport ]; then
  sed -i 's,^enabled=1,enabled=0,g' etc/default/apport
fi

# remove the generated ssh keys so that fresh ones are generated on
# first boot for each installed image
rm -f etc/ssh/*key*
# activate the one shot service to recreate them on first boot
mkdir -p etc/systemd/system/multi-user.target.wants
( cd etc/systemd/system/multi-user.target.wants ;  ln -s ../regenerate-ssh-host-keys.service . )

# delete random-seed and machine-id according to https://systemd.io/BUILDING_IMAGES/
# so that they get created unique per machine on first boot
# inspired by: https://github.com/armbian/build/pull/3774
echo "uninitialized" > etc/machine-id
rm -f var/lib/systemd/random-seed var/lib/dbus/machine-id

# if a different default user name was set, parse it into the rename user script
sed -i "s,DEFAULT_USERNAME=linux,DEFAULT_USERNAME=${DEFAULT_USERNAME},g" scripts/rename-default-user.sh

# create an empty xorg.conf.d dir where the xorg config files can go to
mkdir -p ${BUILD_ROOT}/etc/X11/xorg.conf.d

# add support for self built fresher mesa
if [ "${2}" = "armv7l" ]; then
  echo "LD_LIBRARY_PATH=/opt/mesa/lib/arm-linux-gnueabihf/dri:/usr/lib/arm-linux-gnueabihf/dri" > etc/environment.d/50opt-mesa.conf
  echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/arm-linux-gnueabihf/dri:/usr/lib/arm-linux-gnueabihf/dri" >> etc/environment.d/50opt-mesa.conf
  echo "GBM_DRIVERS_PATH=/opt/mesa/lib/arm-linux-gnueabihf/dri:/usr/lib/arm-linux-gnueabihf/dri" >> etc/environment.d/50opt-mesa.conf
  echo "/opt/mesa/lib/arm-linux-gnueabihf" > etc/ld.so.conf.d/aaa-mesa.conf
elif [ "${2}" = "aarch64" ]; then
  echo "LD_LIBRARY_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" > etc/environment.d/50opt-mesa.conf
  echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "GBM_DRIVERS_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "/opt/mesa/lib/aarch64-linux-gnu" > etc/ld.so.conf.d/aaa-mesa.conf
elif [ "${2}" = "i686" ]; then
  echo "LD_LIBRARY_PATH=/opt/mesa/lib/i386-linux-gnu/dri:/usr/lib/i386-linux-gnu/dri" > etc/environment.d/50opt-mesa.conf
  echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/i386-linux-gnu/dri:/usr/lib/i386-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "GBM_DRIVERS_PATH=/opt/mesa/lib/i386-linux-gnu/dri:/usr/lib/i386-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "/opt/mesa/lib/i386-linux-gnu" > etc/ld.so.conf.d/aaa-mesa.conf
elif [ "${2}" = "x86_64" ]; then
  echo "LD_LIBRARY_PATH=/opt/mesa/lib/x86_64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" > etc/environment.d/50opt-mesa.conf
  echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/x86_64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "GBM_DRIVERS_PATH=/opt/mesa/lib/x86_64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "/opt/mesa/lib/x86_64-linux-gnu" > etc/ld.so.conf.d/aaa-mesa.conf
elif [ "${2}" = "riscv64" ]; then
  echo "LD_LIBRARY_PATH=/opt/mesa/lib/riscv64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" > etc/environment.d/50opt-mesa.conf
  echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/riscv64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "GBM_DRIVERS_PATH=/opt/mesa/lib/riscv64-linux-gnu/dri:/usr/lib/x86_64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
  echo "/opt/mesa/lib/riscv64-linux-gnu" > etc/ld.so.conf.d/aaa-mesa.conf
fi
cp etc/environment.d/50opt-mesa.conf etc/X11/Xsession.d/50opt-mesa.conf
echo "export LD_LIBRARY_PATH LIBGL_DRIVERS_PATH GBM_DRIVERS_PATH" >> etc/X11/Xsession.d/50opt-mesa.conf

# add some imagebuilder version info as /etc/imagebuilder-info
IMAGEBUILDER_VERSION=$(cd ${WORKDIR}; git rev-parse --verify HEAD)
echo ${1} ${2} ${3} ${IMAGEBUILDER_VERSION} > ${BUILD_ROOT}/etc/imagebuilder-info

# copy postinstall files into the build root if there are any
if [ -d ${DOWNLOAD_DIR}/postinstall-${1} ]; then
  cp -r ${DOWNLOAD_DIR}/postinstall-${1} ${BUILD_ROOT}/postinstall
fi

# post install script per system
if [ -f ${WORKDIR}/systems/${1}/postinstall.sh ]; then
  bash ${WORKDIR}/systems/${1}/postinstall.sh ${1} ${2} ${3}
fi

# post install script which is run chrooted per system
if [ -f ${WORKDIR}/systems/${1}/postinstall-chroot.sh ]; then
  cp ${WORKDIR}/systems/${1}/postinstall-chroot.sh ${BUILD_ROOT}/postinstall-chroot.sh
  chmod a+x ${BUILD_ROOT}/postinstall-chroot.sh
  chroot ${BUILD_ROOT} /postinstall-chroot.sh ${1} ${2} ${3}
  rm -f ${BUILD_ROOT}/postinstall-chroot.sh
fi

# cleanup postinstall files
if [ -d ${BUILD_ROOT}/postinstall ]; then
  rm -rf ${BUILD_ROOT}/postinstall
fi

# recompile glib schemas to enable our onboard settings
chroot ${BUILD_ROOT} glib-compile-schemas /usr/share/glib-2.0/schemas/

# remove libreoffice and do a final cleanup to get the size of the image down a bit
chroot ${BUILD_ROOT} apt-get -y remove --purge libreoffice*
chroot ${BUILD_ROOT} apt-get -y auto-remove
chroot ${BUILD_ROOT} apt-get -y clean

chroot ${BUILD_ROOT} ldconfig

if [ "${PMOSKERNEL}" != "true" ]; then
  export KERNEL_VERSION=`ls ${BUILD_ROOT}/boot/*Image-* | sed 's,.*Image-,,g' | sort -u`

  # in case we did not get a kernel version, try it again with the vmlinuz
  if [ "$KERNEL_VERSION" = "" ]; then
    echo "trying vmlinuz as kernel name instead of *Image:"
    export KERNEL_VERSION=`ls ${BUILD_ROOT}/boot/vmlinuz-* | sed 's,.*vmlinuz-,,g' | sort -u`
  fi

  if [ "$KERNEL_VERSION" = "" ]; then
    echo "no KERNEL_VERSION - lets assume this is intended and ignore the initramfs rebuild"
  else
    # hack to get the fsck binaries in properly even in our chroot env
    cp -f usr/share/initramfs-tools/hooks/fsck tmp/fsck.org
    sed -i 's,fsck_types=.*,fsck_types="vfat ext4",g' usr/share/initramfs-tools/hooks/fsck
    chroot ${BUILD_ROOT} update-initramfs -c -k ${KERNEL_VERSION}
    mv -f tmp/fsck.org usr/share/initramfs-tools/hooks/fsck
  fi
else
  # the pmos boot.img reads its initrd extension from here (if not in boot-and-modules.tar.gz)
  if [ -f boot/extra/initramfs-extra ]; then
    cp boot/extra/initramfs-extra boot
  fi
fi

cd ${WORKDIR}

umount ${BUILD_ROOT}/proc ${BUILD_ROOT}/sys ${BUILD_ROOT}/dev/pts ${BUILD_ROOT}/dev

echo ""
echo "now run create-image.sh ${1} ${2} ${3} to build the image"
echo ""
