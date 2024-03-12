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

Note: You will need atleast a 16GB sized USB Drive/SD Card!

> These instructions are for the Kukui baseboard line of Chromebooks ONLY! You will also need sudo permissions, developer mode, and USB boot enabled.

## 1. Downloading, extracting, and flashing the disk image

First, we will need to download the image file. Download the image you want in the "Disk Image Releases" section below (NOTE: Try to select the latest image).

### Disk Image Releases (Hosted on MEGA.nz)

[Ubuntu 22.04](https://mega.nz/file/2McigCCK#qqGJ4vrkecRVWKscxhQ1kxS5uKA9Vl64hsRJG534QVs)

[Ubuntu 23.10](https://mega.nz/file/LEtk3RLb#BCBwhxv7yO6SKarAlZj54r4979ANJRtV3qY6-bAuejM)


Now, open up a terminal and type and ```cd``` into the directory where the downloaded image is (usually ~/Downloads).

> WARNING: The next step will ERASE all of the data on the target drive.

Then, type in ```cat ubuntu-unity.img.gz | gunzip | sudo dd of=/dev/TARGET```

> Make sure to replace TARGET with the device node of your target USB/SD Card (eg. sda, sdb, mmcblk0).

## 2. Booting into the USB/SD Card

> Remember! This guide always assumes you have developer mode with usb booting enabled.

Insert the USB/SD Card into one of the available USB ports (do not use a USB/SD Card dongle, it will not work!)
                                                                                                   
Then, turn on the computer and press CTRL+U to boot into the USB.

> NOTE: The username is linux and the password is ubuntuunity

Login with the username and password above.

Once you reach the Unity Desktop, open up the terminal.

Then, type in ```sudo bash /scripts/extend-rootfs.sh```

This will increase the size of the root partition from the default size of ~16GB and make it the highest it can go, to get the most disk space.

## 3. Installing to internal storage (optional)

Follow all of step 1, but replace TARGET with the device node of the internal storage (usually mmcblk0).

# Make your own Ubuntu Unity USB/SD Card

## 1. Flashing the USB

> These instructions are for the Kukui baseboard line of Chromebooks ONLY! You will also need sudo permissions.

Download the latest Hexdump0815 Imagebuilder Ubuntu image from here: [https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz](https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz)

Extract the image with an archive manager of your choice (eg. file-roller, xarchiver, etc.) that supports img.gz archives.

Then, open up a terminal. Go to the directory where the image is located in. Then flash the image with ```sudo dd if=/dev/IMG of=/dev/TARGET```

> WARNING: THIS STEP WILL ERASE ALL DATA ON THE TARGET DRIVE!

Make sure to replace IMG with the name of the image file, and replace TARGET with the device node you want to flash to (eg. sda, sdb, mmcblk0, etc.)

## 2. Using the script

> NOTE: This guide assumes you have Developer Mode and USB booting enabled already!

Insert the USB/SD Card that you flashed the image onto and insert it into the USB port.

Then, turn on the Chromebook and press CTRL+U to boot into the USB Drive.

Once you reach the login screen, in the username field, type in linux, and in the password field type in changeme.

Then, click on the network icon in the panel and connect to a Wi-Fi network.

After that, open the terminal.

Type in ``` sudo apt update && sudo apt install git -y ```. This command will install Git.

Then, type in ```cd ~ && git clone https://github.com/chromebook-unity/create-usb && cd create-usb && bash first.sh```

> NOTE: After running the script, the username is still linux. The password is whatever you have set when running the script.

After the script reboots your computer, log back in, open the terminal, and run second.sh, in the same directory.

## 3. Upgrading the system (optional but recommended)

It is recommended to upgrade the image to the latest LTS (eg. 22.04) or the latest LTS Devel release (23.04, 23.10, etc.)

To do this, open up a terminal window, and type in ```cd ~/create-usb && bash update-image.sh```

Then, the script will run a few commands, and you will need to select the release you want to upgrade to.

## License Info
Ubuntu Unity is licensed under the GPLv3 license and includes components from other open-source projects, such as the Unity Desktop.
