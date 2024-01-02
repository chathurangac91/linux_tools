#!/bin/bash

if [[ $UID -ne 0 ]]; then
   echo -e "\e[95mYou must be root to do this.\e[0m" 1>&2
   exit 100
fi

echo -e "\e[96mDo you want to configure Wondershaper Bandwidth Limiter?\e[0m"
read -p "Enter choice (y/n): " -n 1 -r
echo  # Move to the next line after the user input

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\e[96mInstalling and setup Wondershaper\e[0m"
    apt install wondershaper net-tools -y

    echo -e "\e[96mHow much remaining bandwidth is there on your server?\e[0m"

	while true; do
	    read -p "Enter in TB: " tb

	    # Check if tb is a number
	    if [[ $tb =~ ^[0-9]+$ ]]; then
	        break  # Exit the loop if tb is a number
	    else
	        echo -e "\e[91mInvalid input. Please enter a valid number.\e[0m"
	    fi
	done

	echo -e "\e[96mHow many days do you want to use this bandwidth?\e[0m"

	while true; do
	    read -p "Enter a number: " days

	    # Check if tb is a number
	    if [[ $days =~ ^[0-9]+$ ]]; then
	        break  # Exit the loop if tb is a number
	    else
	        echo -e "\e[91mInvalid input. Please enter a valid number.\e[0m"
	    fi
	done

	tbInBytes=$((tb * 1000000000000))
	daysInSeconds=$((days * 86400))
	speedLimitInKbps=$((tbInBytes / daysInSeconds * 8 / 1000))
	roundedSpeedLimit=$(echo "scale=0; $speedLimitInKbps / 1" | bc -l)
	speedLimitInMbps=$((speedLimitInKbps / 1000))

	echo -e "\e[96mThe maximum download speed will be $speedLimitInMbps Mbps\e[0m (The actual speed may vary due to several reasons). Are you sure you want to continue with these configurations?"
	read -p "Enter choice (y/n): " -n 1 -r
	echo  # Move to the next line after the user input

	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Using the ip command to retrieve the name of the active network interface
		interface_name=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | head -n1)
		wondershaper clear $interface_name
		wondershaper $interface_name $speedLimitInKbps $speedLimitInKbps
		(crontab -l | grep -v -F "@reboot wondershaper" ; echo "@reboot wondershaper $interface_name $roundedSpeedLimit $roundedSpeedLimit") | crontab -

	fi
fi