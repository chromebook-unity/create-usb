rel=noble
prevrel=jammy

if [[ "$EUID" -ne 0 ]]; then
    echo "Script not ran as root, please enter your password to enter root.."
    sudo bash auto.sh
fi
# Some parts of script taken from imagebuilder repo by hexdump0815
export DEBIAN_FRONTEND=noninteractive

export LANG=C
apt-get update
apt-get -y install debootstrap btrfs-progs
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
mkdir mnt
mkdir out
export BUILD_ROOT=/root/
export BUILD_ROOT_CACHE=/cache/
export DOWNLOAD_DIR=$PWD/download/
export MOUNT_POINT=$PWD/mnt/
export IMAGE_DIR=$PWD/out/
BOOTPARTLABEL="bootpart"
ROOTPARTLABEL="rootpart"
apt install binfmt-support qemu-user-static cgpt -y
systemctl start binfmt-support.service

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
LANG=C sudo debootstrap --variant=minbase --arch=${BOOTSTRAP_ARCH} $prevrel ${BUILD_ROOT_CACHE} http://${SERVER_PREFIX}ubuntu.com/${SERVER_POSTFIX}
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
echo "apt update && apt upgrade -y && apt-get -yq install locales vim openssh-server ssh-askpass sudo net-tools ifupdown iputils-ping kmod less rsync u-boot-tools usbutils dosfstools mesa-utils mesa-utils-extra console-data linux-firmware lvm2 cryptsetup-bin cryptsetup-initramfs slick-greeter rsyslog btrfs-progs btrfs-compsize dialog cgpt lz4 vboot-kernel-utils -label xserver-xorg-video-fbdev xinput rfkill curl gnome-system-tools gnome-system-monitor iptables firmware-sof-signed git strace glmark2 pwgen fdisk gdisk libglib2.0-bin initramfs-tools network-manager" | tee cache/post.sh
chmod +x ${BUILD_ROOT_CACHE}/post.sh
sudo chroot ${BUILD_ROOT_CACHE} /post.sh
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
sudo chroot ${BUILD_ROOT} apt-get update

echo "useradd -c unity -d /home/unity -m -s /bin/bash unity && echo "unity:ubuntu" | sudo chpasswd && usermod -a -G sudo unity && usermod -a -G audio unity && usermod -a -G video unity && usermod -a -G render unity && apt-get -yq remove snapd dmidecode && apt-get -yq auto-remove" | tee root/post2.sh
sudo chmod +x ${BUILD_ROOT}/post2.sh
sudo chroot ${BUILD_ROOT} /post2.sh
cd ${BUILD_ROOT}/
rm -rf post2.sh
wget https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.12.28-stb-cbm%2B/6.12.28-stb-cbm+.tar.gz
tar -xvf 6.12.28-stb-cbm+.tar.gz
if [[ "$mtk" == "mt8183" ]]; then
      echo "" >> etc/rc.local
      echo "# additions for ${1}" >> etc/rc.local
      echo "" >> etc/rc.local
      wget https://github.com/velvet-os/imagebuilder/raw/refs/heads/main/systems/chromebook_kukui/rc-local-additions.txt
      cat rc-local-additions.txt >> etc/rc.local
      rm -rf rc-local-additions.txt
fi

if [[ "$mtk" == "mt8173" ]]; then
      echo "" >> etc/rc.local
      echo "# additions for ${1}" >> etc/rc.local
      echo "" >> etc/rc.local
      wget https://github.com/velvet-os/imagebuilder/blob/main/systems/chromebook_oak/rc-local-additions.txt
      cat rc-local-additions.txt >> etc/rc.local
      rm -rf rc-local-additions.txt
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

mkdir -p ${BUILD_ROOT}/etc/X11/xorg.conf.d

echo "LD_LIBRARY_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" > etc/environment.d/50opt-mesa.conf
echo "LIBGL_DRIVERS_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
echo "GBM_DRIVERS_PATH=/opt/mesa/lib/aarch64-linux-gnu/dri:/usr/lib/aarch64-linux-gnu/dri" >> etc/environment.d/50opt-mesa.conf
echo "/opt/mesa/lib/aarch64-linux-gnu" > etc/ld.so.conf.d/aaa-mesa.conf
cp etc/environment.d/50opt-mesa.conf etc/X11/Xsession.d/50opt-mesa.conf
echo "export LD_LIBRARY_PATH LIBGL_DRIVERS_PATH GBM_DRIVERS_PATH" >> etc/X11/Xsession.d/50opt-mesa.conf

if [[ "$mtk" == "mt8173" ]]; then
    cd ${BUILD_ROOT}
    wget https://github.com/velvet-os/imagebuilder/raw/refs/heads/main/systems/chromebook_oak/postinstall.sh 
fi

if [[ "$mtk" == "mt8183" ]]; then
    cd ${BUILD_ROOT}
    wget https://github.com/velvet-os/imagebuilder/raw/refs/heads/main/systems/chromebook_kukui/postinstall.sh
fi
sudo chmod +x ${BUILD_ROOT}/postinstall.sh
sudo chroot ${BUILD_ROOT} /postinstall.sh
rm -rf ${BUILD_ROOT}/postinstall.sh

# recompile glib schemas to enable our onboard settings
sudo chroot ${BUILD_ROOT} glib-compile-schemas /usr/share/glib-2.0/schemas/

# remove libreoffice and do a final cleanup to get the size of the image down a bit
sudo chroot ${BUILD_ROOT} apt-get -y remove --purge libreoffice*
sudo chroot ${BUILD_ROOT} apt-get -y auto-remove
sudo chroot ${BUILD_ROOT} apt-get -y clean

sudo chroot ${BUILD_ROOT} ldconfig
cd ${BUILD_ROOT}
wget https://github.com/chromebook-unity/create-usb/raw/refs/heads/main/first.sh
sudo chmod +x ${BUILD_ROOT}/first.sh
chroot ${BUILD_ROOT} /first.sh
sudo rm -rf ${BUILD_ROOT}/first.sh
cd ${WORKDIR}
truncate -s 5187M ${IMAGE_DIR}/ubuntuunity-$rel-$mtk$(date +"%B-%d-%Y").img
sudo losetup /dev/loop0 ${IMAGE_DIR}/ubuntuunity-$rel-$mtk$(date +"%B-%d-%Y").img
umount ${BUILD_ROOT}/proc ${BUILD_ROOT}/sys ${BUILD_ROOT}/dev/pts ${BUILD_ROOT}/dev
sudo sgdisk -Z /dev/loop0
sudo partprobe /dev/loop0

  # create a fresh partition table and reread it via partprobe
sudo sgdisk -C -e -G /dev/loop0
sudo partprobe /dev/loop0

  # create the chomeos partition structure and reread it via partprobe
cgpt create /dev/loop0
partprobe /dev/loop0


cgpt add -i 1 -t kernel -b 8192 -s 262144 -l KernelA -S 1 -T 2 -P 10 /dev/loop0
cgpt add -i 2 -t kernel -b 270336 -s 262144 -l KernelB -S 0 -T 2 -P 5 /dev/loop0

# this is to make sure we really use the new partition table and have all partitions around
partprobe /dev/loop0

mkfs -t ext4 -O ^has_journal -m 0 -L $BOOTPARTLABEL /dev/loop0p$BOOTPART

mkfs -t btrfs -m single -L $ROOTPARTLABEL /dev/loop0p$ROOTPART
mount -o ssd,compress-force=zstd,noatime,nodiratime /dev/loop0p$ROOTPART ${MOUNT_POINT}

mkdir ${MOUNT_POINT}/boot
mount /dev/loop0p$BOOTPART ${MOUNT_POINT}/boot

echo "copying over the root fs to the target image - this may take a while ..."
date
rsync -axADHSX --no-inc-recursive ${BUILD_ROOT}/ ${MOUNT_POINT}
date
echo "done"

btrfs subvolume create ${MOUNT_POINT}/swap
chmod 755 ${MOUNT_POINT}/swap
chattr -R +C ${MOUNT_POINT}/swap
truncate -s 0 ${MOUNT_POINT}/swap/file.0
fallocate -l 512M ${MOUNT_POINT}/swap/file.0
chmod 600 ${MOUNT_POINT}/swap/file.0
mkswap -L swapfile.0 ${MOUNT_POINT}/swap/file.0
mount -o bind /dev ${MOUNT_POINT}/dev
mount -o bind /dev/pts ${MOUNT_POINT}/dev/pts
mount -o bind /run ${MOUNT_POINT}/run
mount -t sysfs /sys ${MOUNT_POINT}/sys
mount -t proc /proc ${MOUNT_POINT}/proc
cd ${MOUNT_POINT}/boot
dd if=*vmlinux.kpart* of=/dev/loop0p1 bs=1M status=progress
dd if=*vmlinux.kpart* of=/dev/loop0p2 bs=1M status=progress
sudo touch ${MOUNT_POINT}/etc/fstab
echo "LABEL=$ROOTPARTLABEL / btrfs defaults,ssd,compress-force=zstd,noatime,nodiratime 0 1" | tee -a ${MOUNT_POINT}/etc/fstab
echo "LABEL=$BOOTPARTLABEL /boot ext4 defaults,noatime,nodiratime,errors=remount-ro 0 2" | tee -a ${MOUNT_POINT}/etc/fstab
sed -i 's,LABEL=swappart,/swap/file.0,g' ${MOUNT_POINT}/etc/fstab
echo "Cleaning up..."
umount ${MOUNT_POINT}/boot
mkdir ${MOUNT_POINT}/scripts
cd ${MOUNT_POINT}/scripts
wget https://raw.githubusercontent.com/velvet-os/imagebuilder/d740e50050ce93676c678a2a8bd4be51796c0108/files/extra-files/scripts/extend-rootfs.sh
umount ${MOUNT_POINT}
losetup -d /dev/loop0
rmdir ${MOUNT_POINT}
echo "Done. Your image is located at ${IMAGE_DIR}/ubuntuunity-$rel-$mtk-$(date +"%B-%d-%Y").img"
echo "Summary: Ubuntu Unity $rel, built for $mtk, on $(date +"%B-%d-%Y")"
