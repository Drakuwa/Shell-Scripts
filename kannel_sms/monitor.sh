#!/bin/bash

#Getting the required variables from the caller function
sender=$1 #who sent us the SMS
reciever=$2 #we are the reciever in this case

#declare a function for sending the SMS message
function sendsms(){
	msg=$1 #the message passed to the function is not url coded
	message=$(python -c "import urllib; print urllib.quote('''$msg''')") #we use a simple python command to url code the message
	curl "http://localhost:13013/cgi-bin/sendsms?user=test&password=test&from=$reciever&to=$sender&text=$message"
}

#Start an endless while cycle which checks the port 80, and sends an SMS message if it's closed.
while [ 1 ]
do
	nc -z localhost 80
	#you can use -u for UDP services, -n for not resolving dns names etc...
	#on some distributions 'nc' is called 'netcat'
        if [ $? -eq 0 ]; then
	#everything is OK and now do nothing for the next 5 minutes
        sleep 10
        elif [ $? != 0 ]; then
	#the service is down, send an SMS notification.
	sendsms "The service on port 80 (httpd) is down!"
	sleep 10
        fi
done
