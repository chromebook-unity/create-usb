echo "Running checks..."

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
exit
fi

if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "You are online, continuing..."
  echo ""
else
  echo "Error: You are offline."
  exit
fi

cd ~
HOME=$(pwd)
MNT=/mount-ubuntu-unity
IMG=${HOME}/chromebook_kukui-aarch64-jammy.img

echo "Downloading Image..."
sudo wget https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz
sudo gzip -d chromebook_kukui-aarch64-jammy.img.gz


echo "Mounting image..."

sudo mkdir -p $MNT
OFFSET=$(parted "$IMAGE" unit b print | grep "btrfs" | awk '{ print substr($2,0,length($2)-1) }')
sudo mount -o loop,offset="$OFFSET" "$IMAGE" "$MNT"


sudo mount -t proc /proc "${MNT}/proc/"
sudo mount --rbind /sys "${MNT}/sys/"
sudo mount --rbind /dev $MNT/dev/
sudo mount --rbind /run $MNT/run/

sudo chroot "${MNT} /bin/bash" <<EOF
#!/bin/bash

echo "Welcome to the Ubuntu Unity Conversion (chroot)!"
echo ""
echo "Setting variables..."
KERNEL=$(uname -r)
ARCH=$(uname -m)
echo ""
echo "This script is best made for 8GB USBs/SD Cards if you want to package them into an image file (.img)."
echo ""
echo "Running a few checks..."

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
exit
fi

if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "You are online, continuing..."
  echo ""
else
  echo "Error: You are offline."
  exit
fi

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Running on aarch64, continuing..."
else
    echo "Error: This script is only meant for ARM64 Chromebooks!"
    exit
fi

echo ""
echo "Setting password for user linux..."
passwd linux
echo ""
echo "Setting root password..."
passwd
echo ""
echo "Installing Unity Desktop..."
apt update
apt install ubuntu-unity-desktop -y --no-install-recommends
apt install unity-tweak-tool indicator-* hud -y 
apt purge firefox-esr --autoremove -y
apt purge snapd --autoremove -y
apt install gnome-software -y
echo ""
echo "Installing Brave Browser..."
apt install curl -y
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install brave-browser -y
echo ""
echo "Setting Hostname to ubuntu-unity..."
sudo hostnamectl set-hostname ubuntu-unity
echo ""
echo "Removing XFCE and some remnants of GNOME..."
sudo apt purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* --autoremove -y
sudo apt purge gdm3 gnome-sudoku gnome-shell --autoremove -y
sudo apt upgrade -y --autoremove
sudo apt install gnome-software -y
echo "Removing GIMP to free up space..."
sudo apt purge gimp --autoremove -y
sudo apt clean
echo "Chroot script has finished!"
EOF

echo "Cleaning up..."

umount $MNT/proc
umount -l $MNT/sys
umount -l $MNT/dev
umount -l $MNT/run
