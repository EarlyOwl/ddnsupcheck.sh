#!/bin/bash

#Github: EarlyOwl/ddnsupcheck.sh
#ver 1.0.0 -- This script is licensed under the MIT License

#=======EDIT THE FOLLOWING 3 VARIABLES TO FIT YOUR ENVIRONMENT=======#
#Your DDNS record to check
ddnsrecord="yourddnsrecord.example.com"

#Path for writing logs and other files. Default is current directory
workpath="."

#Timestamp used for logging. The default format is dd/mm/yyyy#h:m:s
timestamp=$(date +%d/%m/%y@%H:%M:%S)
#====================================================================#

#The logs and other files. You can edit those as well.
logfile="$workpath/log.txt"
iphistoryfile="$workpath/ip_history.txt"
lastrunipfile="$workpath/lastrun_ip.txt"

#Get the public IP from ipinfo.io, store it to var currentip
currentip=$(curl https://ipinfo.io/ip 2>/dev/null)

#Get the IP address associated with your DDNS record with dig, store it to var lookupip
lookupip=$(dig +short $ddnsrecord 2>/dev/null)

#Terminate the execution early if curl fails. Log the error.
if [[ $currentip = "" ]]; then
  echo "[$timestamp][CRIT] Error getting current IP (curl), probably because of lack of connectivity. Terminating execution..." >> $logfile
  exit 1
fi

#Terminate the execution early if dig fails. Log the error.
if [[ $lookupip = "" ]]; then
  echo "[$timestamp][CRIT] DNS resolution (dig) failed, probably because of a wrong DNS record. Terminating execution..." >> $logfile
  exit 1
fi

#Check if the file lastrun_ip.txt exists.
#If it doesn't, it means that this is the first time the script runs.
if [[ ! -f "$lastrunipfile" ]]; then
  #Create the file
  touch $lastrunipfile
  #Save the current ip into the lastrun_ip.txt file
  echo "$currentip" > $lastrunipfile
  #Log the IP inside the ip_history.txt file as well
  echo "[$timestamp] $currentip" >> $iphistoryfile
fi

#Get the IP obtained in the last script run, store it to var lastrunip
lastrunip=$(<$lastrunipfile)

#Overwrite the previous file with the current IP address
echo "$currentip" > $lastrunipfile

#Checks if the IP address has changed since last time
#Case 1: no address change
#(the IP retrieved with curl is the same as the one stored in the file lastrun_ip.txt)
if [[ $currentip = "$lastrunip" ]]; then
  #Log the outcome
  echo "[$timestamp][INFO] No IP change detected since last run. Current IP is $currentip" >> $logfile
  #< - - - - - - - - - - - - - - - - - - - - - - - >
  #You can add additional actions to perform here
  #< - - - - - - - - - - - - - - - - - - - - - - - >
#Case 2: the public IP has changed since last time, but there isn't a record mismatch
#(the IP retrieved with curl is the same as the one obtained with dig)
elif [[ $currentip = "$lookupip" ]]; then
  #Log the outcome
  echo "[$timestamp][WARN] No DNS / IP mismatch, but an IP change was detected" >> $logfile
  echo "[$timestamp][WARN] The old IP address was   : $lastrunip" >> $logfile
  echo "[$timestamp][WARN] The current IP address is: $currentip" >> $logfile
  #Save the new IP to a file named ip_history.txt
  echo "[$timestamp] $currentip" >> $iphistoryfile
  #< - - - - - - - - - - - - - - - - - - - - - - - >
  #You can add additional actions to perform here
  #example: send a notification
  #< - - - - - - - - - - - - - - - - - - - - - - - >
#Case 3: the public IP has changed since last time AND there is a record mismatch
#(the IP retrievied with curl is different from the one obtained with dig)
elif [[ $currentip != "$lookupip" ]]; then
  echo "[$timestamp][CRIT] DNS A record and public IP mismatch!" >> $logfile
  echo "[$timestamp][CRIT] The current A record is : $lookupip" >> $logfile
  echo "[$timestamp][CRIT] The current public IP is: $currentip" >> $logfile
  #Save the new IP to a file named ip_history.txt
  echo "[$timestamp] $currentip" >> $iphistoryfile
  #< - - - - - - - - - - - - - - - - - - - - - - - >
  #You can add additional actions to perform here
  #example: update the record with the correct parameters
  #< - - - - - - - - - - - - - - - - - - - - - - - >
#Case 4: something is not working properly
else
  echo "[$timestamp][FATAL] Ops... Something's wrong" >> $logfile
  echo "[$timestamp][FATAL] DEBUG INFO: var currentip value is $currentip | var lookupip is $lookupip | var lastrunip is $lastrunip"
fi
