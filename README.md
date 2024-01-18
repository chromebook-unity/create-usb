# Instructions to make an Ubuntu Unity ARM Chromebook USB

## Supported Devices

### tested systems - working

- hp chromebook 11a - kappa

### untested systems

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


## 1. Flashing the USB

> These instructions are for the Kukui baseboard line of Chromebooks ONLY! You will also need sudo permissions.

Download the latest Hexdump0815 Imagebuilder Ubuntu image from here: [https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz](https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz)

Extract the image with an archive manager of your choice (eg. file-roller, xarchiver, etc.) that supports img.gz archives.

Then, open up a terminal. Go to the directory where the image is located in. Then flash the image with ``` sudo dd if=/dev/IMG of=/dev/TARGET ```

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

Then, type in ```git clone https://github.com/chromebook-unity/create-usb && cd create-usb && bash first.sh```

> NOTE: After running the script, the username is still linux. The password is whatever you have set when running the script.

After the script reboots your computer, log back in, open the terminal, and run second.sh, in the same directory.
