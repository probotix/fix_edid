# fix_edid
This is a script that fixes the edid data on touchscreen monitors that are incorrectly reporting screen size to the Squeekboard on screen keyboard for the Raspberry Pi 5 causing that keyboard display to be unusably tiny.

It reads the current edid, makes the edits, calculates the checksums, saves the custom edid to /lib/firmware/edid/, then adds the appropriate code to /boot/firmware/cmdline.txt and updates initramfs. Reboot to see the changes.

During debugging, I screwed up several times. It seems like the Pi will fallback to the factory EEPROM edid if it fails. So dont be afraid to try it.

Be sure to measure the approximate dimensions in whole number CM, not MM, and change it in the script. The values in there now are for a 10.1 inch screen. The width and height are as if the screen was in normal landscape rotation. The Pi rotates these for you when you rotate the display settings.

It would be easy to modify the script to handle the second HDMI port as well.
