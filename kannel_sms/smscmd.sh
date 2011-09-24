#!/bin/bash

#Getting the required variables from the SMS message
sender=$1 #who sent us the SMS
reciever=$2 #we are the reciever in this case
command=$3 #what command is passed to the system from the SMS message

#declare a function for sending the SMS message
function sendsms(){
	msg=$1 #the message passed to the function is not url coded
	message=$(python -c "import urllib; print urllib.quote('''$msg''')") #we use a simple python command to url code the message
	curl "http://localhost:13013/cgi-bin/sendsms?user=test&password=test&from=$reciever&to=$sender&text=$message"
}

case $command in
	intIP)
		#get all the internal IP addresses (written in one line as a pair of interface: address)
		intIP=`ip -o addr show | egrep --regexp="(^[2-9]: |^[0-9]{2,}: )[a-zA-Z0-9]*[ ]*inet" | awk '{ printf $2 " " $4 "; " }'`
		sendsms "$intIP"
		;;

	extIP)
		#get the external IP
		extIP=`curl http://whatismyip.org`
		sendsms "Your external IP address is: $extIP"
		;;

	ipv6start)
		#start the gogoc IPv6 service on a system with systemd
		if [ `ps ax | grep -i gogoc | wc -l` -gt "1" ]
		then sendsms "Servisot raboti!"
		else systemctl start gogoc.service; sendsms "Sistemot e uspeshno startuvan!"
		fi
		;;

	wicd)
		#restart wicd service
		systemctl restart wicd.service
		sendsms "Wicd successfully (re)started"
		;;

	uptime)
		#getting the uptime
		uptme="Uptime:"`uptime`
		sendsms "$uptme"
		;;

	temperature)
		#get the core temperature
		temperature=`acpi -t`
		sendsms "$temperature"
		;;

	memory)
		#RAM memmory usage
		mem=`free -m | grep -i Mem | awk '{print "used: " $3 " free: " $4 ", cached: " $7 }'`
		sendsms "$mem"
		;;

	cpuinfo)
		cpuinfo=`cat /proc/cpuinfo | grep "model name" | head -n 1 | awk '{ print substr( $0, 17 )}'`
		sendsms "Model name: $cpuinfo"
		;;

	help)
		sendsms "Available commands: wicd, uptime, temperature, memory, cpuinfo, intIP, extIP, ipv6start"
		;;
	*)	sendsms "usage: 'CMD command' command IN [wicd, uptime, temperature, memory, cpuinfo, intIP, extIP, ipv6start]";;
esac
