# Instructions for use:

# Supported Devices

## tested systems - working

- hp chromebook 11a - kappa
- lenovo ideapad 3 chromebook 14 inch (mt8183 version) - fennel14
- acer chromebook 314 (cb314-2h/cb314-2ht) - cozmo

## untested systems

- acer chromebook 311 (c722/c722t) - willow
- asus chromebook cz1 - cerise
- asus chromebook flip cz1 - stern
- hp chromebook x360 11mk g3 ee - burnet
- lenovo 100e chromebook (mt8183 version) - makomo
- lenovo ideapad duet 10.1 chromebook - krane
- acer chromebook spin cp311-3h - juniper
- lenovo ideapad flex 3 chromebook (mt8183 version) - fennel
- asus chromebook flip cm3 (mt8183 version) - damu
- asus chromebook cm3 - kakadu
- acer chromebook 311 - kenzo
- lenovo 10e chromebook tablet - kodama
- asus chromebook detachable cz1 - katsu
- hp chromebook 11mk g9 ee - burnet/esche


# Use the prebuilt disk image (recommended)

Note: You will need atleast a 8GB sized USB Drive/SD Card!

> These instructions are for the mt8183 and mt8173 line of Chromebooks ONLY! You will also need root, developer mode, and USB boot enabled.

## 1. Downloading and flashing the disk image 

First, we will need to download the image file. Download the image you want in the "Disk Image Releases" section below (NOTE: Try to select the latest image).

### Disk Image Releases (Hosted on MEGA.nz)

[Ubuntu 22.04 (DEPRECATED - USE 24.04)](https://mega.nz/file/2McigCCK#qqGJ4vrkecRVWKscxhQ1kxS5uKA9Vl64hsRJG534QVs)

[Ubuntu 23.10 - Wi-Fi BROKEN - DO NOT USE](https://mega.nz/file/LEtk3RLb#BCBwhxv7yO6SKarAlZj54r4979ANJRtV3qY6-bAuejM)


Now, open up a terminal and ```cd``` into the directory where the downloaded image is (usually ~/Downloads).

> WARNING: THIS STEP WILL ERASE ALL DATA ON THE TARGET DRIVE!

Then, type in ```sudo dd if=[your image location] of=/dev/TARGET bs=1M status=progress```
For Ubuntu 22.04 and 23.10 images (UNSUPPORTED!), run ```cat ubuntu-unity.img.gz | gunzip | sudo dd of=/dev/TARGET```

> Make sure to replace TARGET with the device node of your target USB/SD Card (eg. sda, sdb, mmcblk0), and replace your image location with where your image is located. 

## 2. Booting into the USB/SD Card

> Remember! This guide always assumes you have developer mode with usb booting enabled.

Insert the USB/SD Card you flashed into one of the available USB ports (do not use a USB/SD Card dongle, it will not work!)
                                                                                                   
Then, turn on the computer and press CTRL+U to boot into the USB.

> NOTE: The username is unity and the password is ubuntu
> For Ubuntu 22.04 and 23.10 images, username is linux and password is ubuntuunity

Login with the username and password above.

Once you reach the Unity Desktop, open up the terminal.

Then, type in ```sudo bash /scripts/extend-rootfs.sh```

This will increase the size of the root partition from the default size of ~8GB and make it the highest it can go, to utilize the most disk space.

## 3. Installing to internal storage (optional)

Follow all of step 1, but replace TARGET with the device node of the internal storage (usually mmcblk0).
> If anything goes wrong, or it's unbootable, reinstall chromeOS, or boot your Ubuntu Unity USB drive to fix it.
> Don't hesitate on installing it to the eMMC storage, it wont fail as long you do it right. 

# Make your own Ubuntu Unity Image
Run auto.sh from this repository (on Ubuntu/Debian!) and flash the image generated to a USB Drive or SD Card. You can also tweak the script, like changing the Ubuntu version, kernel, etc.
## License Info
Ubuntu Unity is licensed under the GPLv3 license and includes components from other open-source projects, such as the Unity Desktop.
