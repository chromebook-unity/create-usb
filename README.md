# Instructions to use this script

## 1. Flashing the USB

> These instructions are for Linux ONLY! You will also need sudo permissions.

Download the latest Hexdump0815 Imagebuilder Ubuntu image from here: [https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz](https://github.com/hexdump0815/imagebuilder/releases/download/230917-01/chromebook_kukui-aarch64-jammy.img.gz)

Extract the image with an archive manager of your choice (eg. file-roller, xarchiver, etc.) that supports img.gz archives.

Then, open up a terminal. Go to the directory where the image is located in. Then flash the image with ``` sudo dd if=/dev/IMG of=/dev/TARGET ```

> WARNING: THIS STEP WILL ERASE ALL DATA ON THE TARGET DRIVE!

Make sure to replace IMG with the name of the image file, and replace TARGET with the device node you want to flash to (eg. sda, sdb, mmcblk0, etc.)

## 2. Using the script

> NOTE: This guide assumes you have enabled Developer Mode and USB booting!

Insert the USB/SD Card that you flashed the image onto and insert it into the USB port.

Then, turn on the Chromebook and press CTRL+U to boot into the USB Drive.

Once you reach the login screen, in the username field, type in linux, and in the password field type in changeme.

Then, click on the network icon in the panel and connect to a Wi-Fi network.

After that, open the terminal.

Type in ``` sudo apt update && sudo apt install git -y ```. This command will install Git.

Then, type in ```git clone https://github.com/aneeshlingala/unity-conversion && cd unity-conversion && bash first.sh```

> NOTE: After running the script, the username is still linux. The password is whatever you have set when running the script.

After the script reboots your computer, log back in, open the terminal, and run second.sh, in the same directory.
