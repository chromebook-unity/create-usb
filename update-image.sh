#!/bin/bash

echo "Welcome to the Ubuntu Image Upgrader!"
sudo apt update
echo "Upgrading packages.."
sudo apt upgrade -y
echo "Installing packages needed for upgrading..."
sudo apt install update-manager-core -y
PS3='What upgrade would you like to do? '
options=("Upgrade to next LTS (ex. 22.04, etc.)" "Upgrade to next devel LTS release (ex. 23.04, 23.10, etc.)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Upgrade to next LTS (ex. 22.04, etc.)")
            echo "Upgrading to next LTS (ex. 22.04, etc.)"
            sudo sed -i 's/^\(Prompt=\).*$/\1lts/' /etc/update-manager/release-upgrades
            sudo do-release-upgrade
            ;;
        "Upgrade to next devel LTS release (ex. 23.04, 23.10, etc.)")
            echo "Upgrading to next devel LTS release (ex. 23.04, 23.10, etc.)"
            sudo sed -i 's/^\(Prompt=\).*$/\1normal/' /etc/update-manager/release-upgrades
            sudo do-release-upgrade
            ;;
        "Quit")
            echo "Quitting..."
            exit
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

