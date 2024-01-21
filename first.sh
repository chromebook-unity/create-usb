#!/bin/bash

echo "Welcome to the Ubuntu Unity Conversion tool!"
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

echo "Extending rootfs..."
sudo bash /scripts/extend-rootfs.sh
echo ""
echo "Setting password for user linux..."
passwd
echo ""
echo "Setting root password..."
sudo passwd
echo ""
echo "Installing Unity Desktop..."
sudo apt update
sudo apt install ubuntu-unity-desktop -y --no-install-recommends
sudo apt install unity-tweak-tool indicator-* hud -y 
sudo apt purge firefox-esr --autoremove -y
sudo apt purge snapd --autoremove -y
sudo apt install gnome-software -y
echo ""
echo "Installing Brave Browser..."
sudo apt install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y
echo ""
echo "Setting Hostname to ubuntu-unity..."
sudo hostnamectl set-hostname ubuntu-unity
echo ""
sleep 7
clear
echo "The Ubuntu Unity Conversion Script has finished..."
echo ""
echo "Rebooting in 10 seconds... (Press CTRL+C to cancel reboot)"
echo "" 
echo "After rebooting, at the login screen, click on the icon near the password field and select Unity, then log in. After that, open the terminal, and run second.sh, in the same directory."
sleep 10
systemctl reboot


