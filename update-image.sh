#!/bin/bash

echo "Welcome to the Ubuntu Image Upgrader!"
sudo apt update
echo "Upgrading packages.."
sudo apt upgrade -y
echo "Installing packages needed for upgrading..."
sudo apt install update-manager-core -y

OLD=$(sed 's/UBUNTU_CODENAME=//;t;d' /etc/os-release)
read -p "Enter the Ubuntu Version you want to upgrade to. For example, mantic, for Ubuntu 23.10. (CASE-SENSITIVE - DO NOT PUT IN A FULL NAME): " NEW

echo "The upgrading process has started!"

sudo sed -i s/$OLD/$NEW/ /etc/apt/sources.list
sudo apt-get update
sudo apt dist-upgrade -y
sudo apt autoremove -y

