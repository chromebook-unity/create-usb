#!/bin/bash

echo "Welcome to the second part of the Ubuntu Unity Conversion Script!"
echo "Removing XFCE and some remnants of GNOME..."
sudo apt purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* --autoremove -y
sudo apt purge gdm3 gnome-sudoku gnome-shell --autoremove -y
sudo apt upgrade -y --autoremove
sudo apt install gnome-software -y
echo "Removing GIMP to free up space..."
sudo apt purge gimp --autoremove -y
sudo apt clean
echo "The second part of the Ubuntu Unity Conversion Script has finished..."
echo "Rebooting in 10 seconds... (Press CTRL+C to cancel reboot)"
sleep 10
