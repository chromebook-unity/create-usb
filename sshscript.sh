#!/usr/bin/env bash

IMAGE="https://matix.li/2d364a4cc247"
FILE_NAME="ubuntu-unity.img.gz"
MOUNT_NODE="/dev/mapper/loop0"
RESOLV_CONF="/etc/resolv.conf"
IMG_NAME="ubuntu-unity.img"
sudo mkdir /mnt/chroot
sudo mkdir /mnt/chroot/chroot
sudo mkdir /mnt/chroot/downloads
CHROOT_DIR="/mnt/chroot/chroot"
DOWNLOAD_DIR="/mnt/chroot/downloads"

read -r -p "Would you like to make a new chroot? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        if [ -d "$CHROOT_DIR" ]; then
          echo "WARNING: THERE IS ALREADY A DIRECTORY LOCATED AT $(echo $CHROOT_DIR), DO YOU WANT TO DELETE THIS DIRECTORY?"
          read -r -p "Response: [y/N] " response
          if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
          then
              echo "Okay, deleting directory..."
              sudo rm -rf $CHROOT_DIR
          else
              echo "ERROR: OPERATION HALTED!"
              exit
          fi
          echo "Downloading Image..."
          cd $DOWNLOAD_DIR
          echo "Clearing Older Images in 10 seconds... (PRESS CTRL+C to QUIT)"
          sleep 10
          sudo rm -rf *
          sudo wget $IMAGE --output-document=$FILE_NAME
          echo "Extracting Image..."
          sudo gzip -d ./$FILE_NAME
          echo "Installing and Setting up KpartX..."
          sudo apt install kpartx -y
          sudo kpartx -av $IMG_NAME
          echo "Mounting Image File..."
          sudo mount $(echo $MOUNT_NODE)p3 $CHROOT_DIR
          sudo mount $(echo $MOUNT_NODE)p2 $CHROOT_DIR/boot
          sudo mount -o bind /dev $CHROOT_DIR/dev
          sudo mount -o bind /dev/pts $CHROOT_DIR/dev/pts
          sudo mount -o bind /proc $CHROOT_DIR/proc
          sudo mount -o bind /sys $CHROOT_DIR/sys
          sudo mount -o bind /run $CHROOT_DIR/run
          sudo rm -rf $CHROOT_DIR/etc/resolv.conf
          sudo cp $RESOLV_CONF $CHROOT_DIR/etc/
          echo 'Chroot has been made successfully.'
        fi
        ;;
    *)
        echo 'Skipping...'
        ;;
esac

read -r -p 'Do you want chroot into the image? [y/N] ' response
case '$response' in
    [yY][eE][sS]|[yY]) 
        echo 'Okay, chrooting...'
        sudo chroot $CHROOT_DIR /bin/bash
        ;;
    *)
        echo 'Skipping...'
        ;;
esac

read -r -p 'Do you want to image your chroot? (THIS KILLS IT!) [y/N]' response
case '$response' in
   [yY][eE][sS]|[yY])
        sudo umount $CHROOT_DIR/dev/pts
        sudo umount $CHROOT_DIR/*
        sudo umount $CHROOT_DIR
        read -p 'Would you like to rename your final image? [y/N]' prompt
        if [[ $prompt =~ [yY](es)* ]]
        then
        echo -n 'Enter new file name:'
        read NEW_NAME 
        sudo mv $DOWNLOAD_DIR/$FILE_NAME $DOWNLOAD_DIR/$(echo $NEW_NAME).img 
        set $FILE_NAME $(echo $NEW_NAME).img
        read -p "Would you like to compress the final image? (y/n): " a;[ "$a" = "y" ]&&{ echo 'Compressing Image...'; cd $DOWNLOAD_DIR; sudo gzip $DOWNLOAD_DIR/$(echo $NEW_NAME); set $FILE_NAME $(echo $NEW_NAME).img.gz; }||echo "Cancelling..."
        echo 'Exiting...'
        fi
         echo 'End of options, exiting...'
         exit
        ;;
esac