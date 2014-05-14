#!/bin/bash

# ======================== #
# Author: Patrick Hennessy #
# Date:   02/16/14	   #
# ======================== #

serverIP=`ifconfig | grep -E 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | sed 's/^\s*//' | cut -f2 -d' '`
serverHostname=`hostname`
serverUptime=`uptime -p | sed 's/up\ //g'`
userLastLogin=`last | grep -v "still" | head -1 | sed -r 's/[\ \t]+/\ /g' | cut -f4,5,6,7 -d' '`
serverUserLoad=`who | wc -l`

# Dynamically creates the MOTD section titles based on the title string width and a bar width
function bar {
	str="\e[1;34m" #1;34 is bold blue color
	title=''	#Init the title variable to blank in case no title is given

	#If title exists, we need to calculate for it
	if [[ $1 != '' ]]; then
		title=":\e[1;37m $1 \e[1;34m:"
		titlelen=`echo ": $1 :" | wc -m`
		sideLen=`expr $2 - $titlelen`
		sideLen=`expr $sideLen / 2`
	else
		titlelen=0
		sideLen=0
	fi

	for i in $(seq 0 `expr $2 - $titlelen`) 	# $2 is the bar width, subtracted the title length without color codes
	do
		if [[ $i -eq $sideLen ]]; then		# We print the title directly in the middle
			str="$str$title"
		else
			str="$str="
		fi
	done
	
	echo -e $str
}

# Prints the status of the specified daemon
function statusd {
	daemon=$1	# Name of the daemon

	# Ask server for status on daemon, get the time since the last action was taken
	since=`systemctl status $daemon | grep "Active" | sed 's/^[\ \t]*//g' | grep -o -E '[A-Za-z]{3}\ [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed 's/\x0$//g'`
	
	# Get seconds between then and now
	SECONDS=`expr $(date +"%s") - $(date --date="$since" +"%s")`

	# Print the journal status for the daemon
	echo -n `systemctl status $daemon | grep "^\ *Active" | sed 's/^[\t\ ]*//g' | cut -f2,3 -d' ' | sed -e 's/^a/A/g' -e 's/^i/I/g' -e s/\ *since\ *//g`
	
	# Calculate the time since using some sweet math skillz
	echo " `expr $SECONDS / 60 / 60 / 24`d `expr $SECONDS / 60 / 60 % 24`h `expr $SECONDS / 60 % 60`m `expr $SECONDS % 60`s"
}

function printStat {
	printf "\e[1;34m= \e[0;36m%-10.10s \e[1;34m= \e[0;37m%-32.32s \e[1;34m=\n"  "$1" "$2"
}

function printLine {
	if [[ `echo $1 | wc -m` -gt 45 ]]; then
		printf "\e[1;34m= \e[0;37m%-42.42s... \e[1;34m=\n"  "$1"
	else	
		printf "\e[1;34m= \e[0;37m%-45.45s \e[1;34m=\n"  "$1"	
	fi
}

if [[ $USER = 'root' ]]; then
	rootWarning=`who | grep $USER | wc -l`
	httpdStatus=`statusd 'httpd'`
	namedStatus=`statusd 'named'`
	sshdStatus=`statusd 'sshd'`
	fail2banStatus=`statusd 'fail2ban'`
	sshguardStatus=`statusd 'sshguard'`
	cronieStatus=`statusd 'cronie'`
	ntpStatus=`statusd 'ntpd'`
	fwallStatus=`statusd 'iptables'`
	postfixStatus=`statusd 'postfix.service'`

	if [[ $rootWarning -gt 0 ]]; then
		bar "WARNING" 50
			echo -e "\e[1;34m+ \e[1;31mSSH breech! $USER should not be able to login"
			echo -e "\e[1;34m+ \e[1;31mRemote IP for $USER: \e[0;37m`who | grep $USER | sed -r 's/[\ \t]+/\ /g' | cut -f5 -d' ' | sort | uniq | cut -f1 -d\. | sed -e 's/[()]//g' -e 's/-/\./g'`"

	fi	

	bar 'System Info' 50
		printStat "IP Address" "$serverIP"
		printStat "Sys Uptime" "$serverUptime"
		printStat "Last Login" "$userLastLogin"
		printStat "User Load" "$serverUserLoad"
	bar 'Daemon Status' 50
		printStat "httpd" "$httpdStatus"
		printStat "named" "$namedStatus"
		printStat "sshd" "$sshdStatus"
		printStat "f2b" "$fail2banStatus"
		printStat "sshgd" "$sshguardStatus"
		printStat "cronie" "$cronieStatus"
		printStat "ntp" "$ntpStatus"
		printStat "iptables" "$fwallStatus"
		printStat "postfix" "$postfixStatus"
	bar 'Pending Tasks' 50
		if [[ `wc -m < ~/.todo` -gt 1 ]]; then
			while read line; do
				if [[ ! $line =~ ^[\ \t]*$ ]]; then
					printLine "$line"
				fi
			done < ~/.todo
		else
			printLine "No pending tasks"
		fi
			
	bar '' 49

else
	bar 'System Info' 50
		printStat "Hostname" "$serverHostname"
		printStat "IP Address" "$serverIP"
		printStat "Sys Uptime" "$serverUptime"
		printStat "Last Login" "$userLastLogin"
		printStat "User Load" "$serverUserLoad"
	bar 'Pending Tasks' 50
		if [[ `wc -m < ~/.todo` -gt 1 ]]; then
			while read line; do
				if [[ ! $line =~ ^[\ \t]*$ ]]; then
					printLine "$line"
				fi
			done < ~/.todo
		else
			printLine "No pending tasks"
		fi
	bar '' 49
	echo -e -n "\e[0m"

fi
