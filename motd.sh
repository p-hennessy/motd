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
	bar 'System Info' 50
		echo -e "\e[1;34m+\e[0;36m IP Address \e[1;34m= \e[0;37m`ifconfig | grep -E 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | sed 's/^\s*//' | cut -f2 -d" "`"
		echo -e "\e[1;34m+\e[0;36m Uptime     \e[1;34m= \e[0;37m`uptime -p | sed 's/up\ //g'`"
		echo -e "\e[1;34m+\e[0;36m User Count \e[1;34m= \e[0;37m`who | cut -f1 -d' ' | sort | uniq | wc -l`"
	bar 'Daemons' 50
		echo -e -n "\e[1;34m+\e[0;36m Apache  \e[1;34m= \e[0;37m"; statusd 'httpd'
		echo -e -n "\e[1;34m+\e[0;36m Bind    \e[1;34m= \e[0;37m"; statusd 'named'
		echo -e -n "\e[1;34m+\e[0;36m SSH     \e[1;34m= \e[0;37m"; statusd 'sshd'	
		echo -e -n "\e[1;34m+\e[0;36m MariaDB \e[1;34m= \e[0;37m"; statusd 'mysqld'
	bar '' 49

else
	bar 'System Info' 50
		echo -e "\e[1;34m+\e[0;36m Hostname \e[1;34m  = \e[0;37m`hostname`"
		echo -e "\e[1;34m+\e[0;36m IP Address \e[1;34m= \e[0;37m`ifconfig | grep -E 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | sed 's/^\s*//' | cut -f2 -d" "`"
		echo -e "\e[1;34m+\e[0;36m Uptime     \e[1;34m= \e[0;37m`uptime -p | sed 's/up\ //g'`"
		echo -e "\e[1;34m+\e[0;36m User Count \e[1;34m= \e[0;37m`who | cut -f1 -d' ' | sort | uniq | wc -l`"
		echo -e "\e[1;34m+\e[0;36m Sessions \e[1;34m  = \e[0;37m`who | grep $USER | wc -l` (\e[1;37m`whoami`\e[0;37m)"
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

fi
