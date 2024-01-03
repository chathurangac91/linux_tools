#!/bin/bash

if [[ $UID -ne 0 ]]; then
   echo -e "\e[95mYou must be root to do this.\e[0m" 1>&2
   exit 100
fi

echo -e "\e[96mDo you want to remove Wondershaper Bandwidth Limiter?\e[0m"
read -p "Enter choice (y/n): " -n 1 -r
echo  # Move to the next line after the user input

if [[ $REPLY =~ ^[Yy]$ ]]; then
	 echo -e "\e[96mUninstalling Wondershaper\e[0m"
	 # Using the ip command to retrieve the name of the active network interface
	# interface_name=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | head -n1)
	interface_name=$(ip route | awk '/default/ {print $5; exit}')
	wondershaper clear $interface_name
	apt remove wondershaper -y
	(crontab -l | grep -v -F "@reboot wondershaper" ; echo "") | crontab -
fi