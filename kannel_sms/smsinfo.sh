#!/bin/bash

#Getting the required variables from the SMS message
sender=$1 #who sent us the SMS
reciever=$2 #we are the reciever in this case
command=$3 #what command is passed to the system from the SMS message
email=$4 #the e-mail address where we will send the screenshot is passed as an SMS argument
email=`echo $email | sed 's/%40/@/g'`

#declare a function for sending the SMS message
function sendsms(){
	msg=$1 #the message passed to the function is not url coded
	message=$(python -c "import urllib; print urllib.quote('''$msg''')") #we use a simple python command to url code the message
	curl "http://localhost:13013/cgi-bin/sendsms?user=test&password=test&from=$reciever&to=$sender&text=$message"
}

case $command in
	snapshot)
		#taking snapshot from webcam
		if [ ${email:-0} = "0" ] #if the email variable is not set (not passed as an argument), set it to 0
                then sendsms "No e-mail specified! Please try again [INFO snapshot user@domain.com]"
                else
		timestamp=`date '+%d-%b-%y_%H-%M-%S'`

		#now take 4 snapshots from the webcam (the camera need 2-3 frames to initialize)
		mplayer tv:// -tv driver=v4l2:width=640:height=480:device=/dev/video0 -frames 4 -vo png
		#send e-mail via mutt with the snapshot as attachement
		mutt -s "Snapshot from webcam taken on: $timestamp" $email < /etc/issue.net -a $HOME/Documents/development/ednoleto/00000004.png
		#remove the remaining snapshots
		rm $HOME/Documents/development/ednoleto/0000000*
		
		fi
		#Mplayer will save a file 0000000n.jpg with a snapshot, where n is 1,2,3 and 4
		#Mplayer uses ffmpeg to do the conversion, so you will usually need the ffmpeg suite installed too.
		;;

	screenshot)
		#part for saving current screenshots
		if [ ${email:-0} = "0" ] #if the email variable is not set (not passed as an argument), set it to 0
		then sendsms "No e-mail specified! Please try again [INFO screenshot user@domain.com]"
		else
		timestamp=`date '+%d%b%y-%N'`;
		scrot screenshot$timestamp.png	#take a screenshot using this simple CLI program
		mutt -s "Screenshot from $timestamp" $email < /etc/issue.net -a screenshot$timestamp.png
		sendsms "screenshot sent to e-mail: $email"
		rm screenshot$timestamp.png
		fi
		;;

	help)
		sendsms "Available commands: snapshot user@domain.com, screenshot user@domain.com"
		;;
	*)	sendsms "usage: 'INFO command' command IN [snapshot user@domain.com, screenshot user@domain.com]";;
esac
