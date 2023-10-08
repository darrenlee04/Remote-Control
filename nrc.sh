#!/bin/bash

#Check user's current working directory and move into Nipe folder
echo 'Your current working directory:'
pwd
echo ''
sleep 1.5

#Move into nipe directory
echo 'Searching for Nipe directory:'
cd nipe
pwd
echo ''

#Start Nipe to make connection become anonymous
echo 'Attempting to start Nipe...'
sudo perl nipe.pl start
sleep 5
echo ''

echo 'Checking connection, please wait...'
echo ''
sleep 1.5

#Check nipe status and grep for "Status: true"
sudo perl nipe.pl status | grep Status | awk '{print $2 $3}'
echo ''
sleep 6

#Create an IF statement that checks if the nipe connection status is true. IF yes (condition matches) echo "You are anonymous"
nipestatus=$(sudo perl nipe.pl status | grep Status | awk '{print $3}')
sleep 2

if [ $nipestatus == 'true' ]
then
	echo "You are annonymous"
else								#The opposite condition
	echo 'You are exposed, Goodbye'
exit
fi
echo ''

#Print out user spoofed IP address
echo 'Your spoofed IP address is:'
sudo perl nipe.pl status | grep Ip | awk '{print $3}'
spoofedIP=$(sudo perl nipe.pl status | grep Ip | awk '{print $3}')
echo ''

#Print out user spoofed country
echo 'Your spoofed country:'
geoiplookup $spoofedIP | grep -i GeoIP | awk -F: '{print $2}' | sort | uniq
echo ''

#Get user input for remote server details
echo 'Remote server credentials'
read -p "Enter remote IP address: " remote_host
read -p "Enter remote username: " remote_user
read -s -p "Enter remote password: " remote_password
echo ''
echo ''
echo 'Connecting to remote server...'
echo ''
sleep 2

#Connect to remote server via sshpass and display it's uptime
echo "Remote server Uptime:"
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'uptime'
echo ''

#Display the remote server's IP address
echo "Remote server IP address:"
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'curl -s ifconfig.me'
sleep 2
echo ''
echo ''

#Display the remote server's country
echo "Remote server country:"
remote_serverIP=$(sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'curl -s ifconfig.me')
geoiplookup "$remote_serverIP" | awk -F: '{print $2}'
sleep 2
echo ''

#Do nmap scan & whoislook victim's IP address/domain on the remote server and save the result
echo "Perform Nmap scanning on victim IP address/domain: "
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'read target; nmap -F -Pn -sV "$target" -vv -oN nmapdata.txt'
echo ''
sleep 1
echo "Nmap scan complete! Results save to nmapdata.txt"
echo ''
sleep 1
echo "Perform Whois lookup on victim IP address/domain: "
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'read target; whois "$target" > whoisdata.txt'
echo ''
sleep 1
echo "Whois lookup complete! Results saved to whoisdata.txt"
echo ''
sleep 1

#Prompt user credential to upload file to local computer
echo "Copying file from remote server to local computer..."
read -p "Enter local server's IP address: " local_host
read -p "Enter local server's username: " local_user
read -s -p "Enter local server's password: " local_password
echo ''
read -p "Enter destination file path on local computer: " destination_file

#Copy file from remote to local machine
sshpass -p "$remote_password" scp "$remote_user@$remote_host:nmapdata.txt" "$destination_file"
sshpass -p "$remote_password" scp "$remote_user@$remote_host:whoisdata.txt" "$destination_file"
echo ''

#List out files on remote server and delete Nmap & Whois data save files
echo "Deleting nmapdata.txt & whoisdata.txt on remote server..."
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'ls'
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'rm nmapdata.txt whoisdata.txt'
echo ''
sleep 2

#List out files on remote server to confirm it's deleted
echo "Files deleted!"
sshpass -p "$remote_password" ssh "$remote_user@$remote_host" 'ls'
echo ''
sleep 2

echo "Exiting remote server..."
echo ''

#Check current logged in user
echo "You're currently logged in as:"
whoami
