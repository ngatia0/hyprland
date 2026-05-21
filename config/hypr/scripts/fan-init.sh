#!/usr/bin/bash

sudo dell-bios-fan-control 0
#echo 190 | sudo tee /sys/class/hwmon/hwmon*/pwm1
sudo systemctl start i8kmon

brightnessctl set 1
sleep 5

DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" notify-send "Fan 󰈐💨" "Control transferred to i8kmon. 👌"

#sudo -u kev0 /home/kev0/.config/hypr/scripts/theme.sh

# To Disable Turbo (Instant Cooling):
# echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
#
# To Enable Turbo (Max Speed):
# echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
