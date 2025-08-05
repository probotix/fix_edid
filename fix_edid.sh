#!/bin/bash

# Where to read and write
EDID_SYS="/sys/class/drm/card1-HDMI-A-1/edid"
EDID_OUT="/lib/firmware/edid/hdmi-custom.edid"

CMDLINE="/boot/firmware/cmdline.txt"
EDID_PARAM="drm.edid_firmware=HDMI-A-1:edid/hdmi-custom.edid"

# Desired screen size (edit these in cm)
width_cm=22
height_cm=13

# Validate input
if ! [[ "$width_cm" =~ ^[0-9]+$ && "$width_cm" -ge 1 && "$width_cm" -le 255 ]]; then
	echo "Invalid width_cm: $width_cm"
	exit 1
fi

if ! [[ "$height_cm" =~ ^[0-9]+$ && "$height_cm" -ge 1 && "$height_cm" -le 255 ]]; then
	echo "Invalid height_cm: $height_cm"
	exit 1
fi

# Temp file
TMP_EDID=$(mktemp)

# Read EDID from sysfs
if [ ! -f "$EDID_SYS" ]; then
	echo "EDID not found at $EDID_SYS"
	exit 1
fi

sudo mkdir -p /lib/firmware/edid

cat "$EDID_SYS" > "$TMP_EDID"

# Patch width (byte 0x15) and height (byte 0x16)
printf "%02x" "$width_cm"  | xxd -r -p | dd of="$TMP_EDID" bs=1 seek=21 count=1 conv=notrunc status=none
printf "%02x" "$height_cm" | xxd -r -p | dd of="$TMP_EDID" bs=1 seek=22 count=1 conv=notrunc status=none

# Recalculate checksum for base block
base_sum=$(head -c 127 "$TMP_EDID" | od -An -t u1 | tr -s ' ' '\n' | awk '{s+=$1} END {print s}')
checksum=$(( (256 - (base_sum % 256)) % 256 ))

# Write new checksum to byte 127
printf "%02x" "$checksum" | xxd -r -p | dd of="$TMP_EDID" bs=1 seek=127 count=1 conv=notrunc status=none

# Copy to firmware path
sudo cp "$TMP_EDID" "$EDID_OUT"

# Cleanup
rm "$TMP_EDID"

echo "EDID patched and saved to $EDID_OUT"
echo "Set width=${width_cm}cm, height=${height_cm}cm, checksum=0x$(printf '%02x' $checksum)"


# Check if parameter already exists
if grep -q "drm.edid_firmware=" "$CMDLINE"; then
	# Replace it using a safe delimiter and full quoting
	sudo sed -i "s|drm.edid_firmware=[^ ]*|${EDID_PARAM}|" "$CMDLINE"
	echo "Updated existing drm.edid_firmware in $CMDLINE"
else
	# Append to the end of the single-line cmdline
	sudo sed -i "\$s|$| ${EDID_PARAM}|" "$CMDLINE"
	echo "Added ${EDID_PARAM} to $CMDLINE"
fi

echo "Updating initramfs..."
sudo update-initramfs -u
echo "initramfs updated"

echo "Reboot To Complete This Mission."


