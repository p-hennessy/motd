#!/bin/bash

clear

function bar {
	str="\e[1;34m"
	title=''

	if [[ $1 != '' ]]; then
		title=":\e[1;37m $1 \e[1;34m:"
		titlelen=`echo ": $1 :" | wc -m`
		sideLen=`expr $2 - $titlelen`
		sideLen=`expr $sideLen / 2`
	else
		titlelen=0
		sideLen=0
	fi

	for i in $(seq 0 `expr $2 - $titlelen`)
	do
		if [[ $i -eq $sideLen ]]; then
			str="$str$title"
		else
			str="$str+"
		fi
	done
	
	echo -e $str
}

function statusd {
	daemon=$1

	since=`systemctl status $daemon | grep "Active" | sed 's/^[\ \t]*//g' | grep -o -E '[A-Za-z]{3}\ [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed 's/\x0$//g'`
	SECONDS=`expr $(date +"%s") - $(date --date="$since" +"%s")`

	echo -n `systemctl status $daemon | grep "^\ *Active" | sed 's/^[\t\ ]*//g' | cut -f2,3 -d' ' | sed 's/^a/A/g'`
	echo " `expr $SECONDS / 60 / 60 / 24`d `expr $SECONDS / 60 / 60 % 24`h `expr $SECONDS / 60 % 60`m `expr $SECONDS % 60`s"
}



if [[ $USER = 'root' ]]; then
	rootWarning=`who | grep $USER | wc -l`

	if [[ $rootWarning -gt 0 ]]; then
		bar "WARNING" 50
			echo -e "\e[1;34m+ \e[1;31mSSH breech! $USER should not be able to login"
			echo -e "\e[1;34m+ \e[1;31mRemote IP for $USER: \e[0;37m`who | grep pat | sed -r 's/[\ \t]+/\ /g' | cut -f5 -d' ' | sort | uniq | cut -f1 -d\. | sed -e 's/[()]//g' -e 's/-/\./g'`"

	fi	

	bar 'System Info' 50
		echo -e "\e[1;34m+\e[0;36m IP Address \e[1;34m= \e[0;37m`ifconfig | grep -E 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | sed 's/^\s*//' | cut -f2 -d" "`"
		echo -e "\e[1;34m+\e[0;36m Sys Uptime \e[1;34m= \e[0;37m`uptime -p | sed 's/up\ //g'`"
		echo -e "\e[1;34m+\e[0;36m Last Login \e[1;34m= \e[0;37m`last | grep -v "still" | head -1 | sed -r 's/[\ \t]+/\ /g' | cut -f4,5,6,7 -d' '`"
		echo -e "\e[1;34m+\e[0;36m User Load  \e[1;34m= \e[0;37m`who | cut -f1 -d' ' | sort | uniq | wc -l`"
	bar 'Service Status' 50
		echo -e -n "\e[1;34m+\e[0;36m httpd      \e[1;34m= \e[0;37m"; statusd 'httpd'
		echo -e -n "\e[1;34m+\e[0;36m named      \e[1;34m= \e[0;37m"; statusd 'named'
		echo -e -n "\e[1;34m+\e[0;36m sshd       \e[1;34m= \e[0;37m"; statusd 'sshd'	
	bar 'Pending Tasks' 50
		if [[ `wc -m < ~/.todo` -gt 1 ]]; then
			while read line; do
				if [[ ! $line =~ ^[\ \t]*$ ]]; then
					echo -e "\e[1;34m+\e[0;37m $line"
				fi
			done < ~/.todo
		else
			echo -e "\e[1;34m+\e[0;37m No pending tasks"
		fi
			
	bar '' 49

else
	bar 'System Info' 50
		echo -e "\e[1;34m+\e[0;36m Hostname \e[1;34m  = \e[0;37m`hostname`"
		echo -e "\e[1;34m+\e[0;36m IP Address \e[1;34m= \e[0;37m`ifconfig | grep -E 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | sed 's/^\s*//' | cut -f2 -d" "`"
		echo -e "\e[1;34m+\e[0;36m Uptime     \e[1;34m= \e[0;37m`uptime -p | sed 's/up\ //g'`"	
		echo -e "\e[1;34m+\e[0;36m Last Login\e[1;34m = \e[0;37m`last | grep -v "still" | head -1 | sed -r 's/[\ \t]+/\ /g' | cut -f4,5,6,7 -d' '`"
		echo -e "\e[1;34m+\e[0;36m User Count \e[1;34m= \e[0;37m`who | cut -f1 -d' ' | sort | uniq | wc -l`"
	bar 'Pending Tasks' 50
		if [[ `wc -m < ~/.todo` -gt 1 ]]; then
			while read line; do
				if [[ ! $line =~ ^[\ \t]*$ ]]; then
					echo -e "\e[1;34m+\e[0;37m $line"
				fi
			done < ~/.todo
		else	
			echo -e "\e[1;34m+\e[0;37m No pending tasks"
		fi
	bar '' 49
	echo "\e[0m"

fi
