# fix_edid

This script fixes incorrect EDID data on certain touchscreen monitors that misreport physical screen size to the Raspberry Pi 5. This misreporting causes the on-screen keyboard (Squeekboard) to appear extremely small or unusable.

The issue is discussed here: [raspberrypi-ui/squeekboard#3](https://github.com/raspberrypi-ui/squeekboard/issues/3)

---

## What It Does

- Reads the current EDID from `/sys/class/drm/card1-HDMI-A-1/edid`
- Patches the screen's physical size (in cm) to the correct values
- Recalculates and corrects the EDID checksum
- Saves the modified EDID to `/lib/firmware/edid/hdmi-custom.edid`
- Adds or updates the `drm.edid_firmware` boot parameter in `/boot/firmware/cmdline.txt`
- Regenerates initramfs so the firmware EDID override is available at boot

After running the script, **reboot** to apply the changes.

---

## Notes

- During development, I made several mistakes — but the Pi is resilient. If the override EDID fails to load, the system typically falls back to the factory EDID stored in EEPROM. So don’t be afraid to experiment.
- Be sure to enter the screen dimensions in **whole number centimeters (cm)** — not millimeters, and as if the screen is in landscape mode (width > height).
- The current script is set for a 10.1" display.
- The Raspberry Pi OS will automatically rotate the reported screen dimensions based on your display rotation settings.
- It should be easy to adapt this script to support the second HDMI port (`card1-HDMI-A-2`).

---

## Example

If your 10.1" screen measures 344mm × 194mm, set the script to:

```bash
width_cm=34
height_cm=19
```

## Warning

This script modifies low-level system files.  
Use it only on Raspberry Pi OS with Wayland (Raspberry Pi 5) and **at your own risk**.  
Always make a backup of `/boot/firmware/cmdline.txt` before editing.

---

## Special Thanks

**Big thanks to [ChatGPT](https://openai.com/chatgpt)** for helping troubleshoot:

- EDID structure and byte offsets  
- Checksum calculation and validation  
- Bash quoting bugs (especially with `sed` and `printf`)  

This script came together faster and with fewer headaches thanks to the help.
