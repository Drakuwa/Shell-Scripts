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
	start)
		#start the port monitor script as a background daemon from its location
		if [ `ps ax | grep -i monitor.sh | wc -l` -gt "1" ]
		then sendsms "The service is already active!"
		else
			sh $HOME/Documents/development/ednoleto/monitor.sh $sender $reciever &
			sendsms "Port monitor service successfuly started!"
		fi
		;;

	stop)
		#stop the port monitor script
		if [ `ps ax | grep -i monitor.sh | wc -l` -gt "1" ]
		then
			kill -9 `ps ax | grep -i monitor.sh | grep "sh " | awk '{print $1}'`
			sendsms "Port monitor stopped!"
		else
			sendsms "Port monitor service is not active!"
		fi
		;;

	help)
		sendsms "Available commands: start, stop"
		;;
	*)	sendsms "usage: 'MONITOR command' command IN [start, stop]";;
esac

