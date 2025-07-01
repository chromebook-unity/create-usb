#!/bin/bash

echo "Installing Unity onto the chroot"
echo ""
echo "Setting variables..."
KERNEL=$(uname -r)
ARCH=$(uname -m)
echo ""
echo ""
echo "Running a few checks..."

if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "You are online, continuing..."
  echo ""
else
  echo "Error: You are offline."
  exit
fi
"Installing Unity Desktop..."
sudo apt update
sudo apt install ubuntu-unity-desktop notification-daemon -y --no-install-recommends
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
echo "Removing GIMP to free up space..."
sudo apt purge gimp --autoremove -y
sudo apt clean
echo ""
sleep 7
clear
echo "The Ubuntu Unity Conversion Script has finished..."
echo ""
echo "Rebooting in 10 seconds... (Press CTRL+C to cancel reboot)"
echo "" 
sleep 10
systemctl reboot


