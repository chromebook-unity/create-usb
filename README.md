# Instructions for use:

# Supported Devices

## tested systems - working

- hp chromebook 11a - kappa

## untested systems

- acer chromebook 311 (c722/c722t) - willow
- asus chromebook cz1 - cerise
- asus chromebook flip cz1 - stern
- hp chromebook x360 11mk g3 ee - burnet
- lenovo 100e chromebook (mt8183 version) - makomo
- lenovo ideapad duet 10.1 chromebook - krane
- acer chromebook spin cp311-3h - juniper
- lenovo ideapad 3 chromebook 14 inch (mt8183 version) - fennel14
- lenovo ideapad flex 3 chromebook (mt8183 version) - fennel
- asus chromebook flip cm3 (mt8183 version) - damu
- asus chromebook cm3 - kakadu
- acer chromebook 314 (cb314-2h/cb314-2ht) - cozmo
- acer chromebook 311 - kenzo
- lenovo 10e chromebook tablet - kodama
- asus chromebook detachable cz1 - katsu
- hp chromebook 11mk g9 ee - burnet/esche


# Use the prebuilt disk image (recommended)

> These instructions are for the Kukui baseboard line of Chromebooks ONLY! You will also need sudo permissions, developer mode, and USB boot enabled.

## 1. Downloading, extracting, and flashing the disk image

First, we will need to download the image file.

The link to the latest image is [located here](https://mega.nz/file/fYMATb5Q#qqGJ4vrkecRVWKscxhQ1kxS5uKA9Vl64hsRJG534QVs). Click on the link to download the image.

Now, open up a terminal and type and ```cd``` into the directory where the downloaded image is.

Then, type in ```cat ubuntu-unity.img.gz | gunzip | sudo dd of=/dev/TARGET```

> Make sure to replace TARGET with the device node of your target USB/SD Card (eg. sda, sdb, mmcblk0).

## 2. Booting into the USB/SD Card

> Remember! This guide always assumes you have developer mode with usb booting enabled.

Insert the USB/SD Card into one of the available USB ports (do not use a USB/SD Card dongle, it will not work!)
                                                                                                   
Then, turn on the computer and press CTRL+U to boot into the USB.

> NOTE: The username is linux and the password is ubuntuunity

Login with the username and password above.

Once you reach the Unity Desktop, open up the terminal.

Then, type in ```sudo bash /scripts/extend-rootfs.sh ```

This will increase the size of the root partition from the default size of ~8GB and make it the highest it can go, to get the most disk space.

## 3. Installing to internal storage (optional)

Follow all of step 1, but replace TARGET with the device node of the internal storage (usually mmcblk0).

# Make your own Ubuntu Unity image


> WARNING: THIS STEP WILL ERASE ALL DATA ON THE TARGET DRIVE!


## 1. Using the script

> NOTE: This guide assumes you have qemu-user-static and git installed. To install it on Debian/Ubuntu, type in ```sudo apt install qemu-user-static git```


Fiest, type in ```sudo git clone https://github.com/chromebook-unity/create-usb && cd create-usb && sudo bash create-img.sh```, to clone the repository and run the image creation script.

> NOTE: After running the script, the username is still linux. The password is whatever you have set when running the script.

## 2. Flashing the image

Once the script finishes, the resulting image will be chromebook_kukui-aarch64-jammy.img

To flash it, run ```sudo dd if=chromebook_kukui-aarch64-jammy.img of=TARGET```

> Make sure to replace TARGET with the device node of your USB/SD Card (eg. sda, sdb, etc.).

## 3. Booting into the image
> Remember! This guide always assumes you have developer mode with usb booting enabled.

After the script is done, insert the USB/SD Card into one of the available USB ports (do not use a USB/SD Card dongle, it will not work!)
                                                                                                   
Then, turn on the computer and press CTRL+U to boot into the USB.
