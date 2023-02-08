#!/usr/bin/env bash

##
## vars
isSudoer=$(id -Gn | grep sudo) # set to 0 to enable bash for all users - $? is the default
userShell="/bin/bash" # specify the shell command
isOkay="" # do not touch
title="Log on to "$(hostname) # change to edit menu titles
showIntro="1" # set to 1 to show intro screen
introMsg="Unauthorised access is prohibited." # change this to modify intro text
userDataStr="" # create a string to hold the user-submitted form data
userDataArr=() # create an array to hold the user-submitted form data
host="" # set default hostname
keyfilePath="~/.ssh/id_ed25519" # set default keyfile
username="${USER}" # set default username


##
## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet >/dev/null 2>&1) # run keychain if it exists


##
## say hola
clear
echo -ne "Performing interactive logon . . . \n"
if [[ "${showIntro}" == "1" ]]; then
	intro=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "${introMsg}" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=$?
fi


##
## gather the data
if [[ "${isSudoer}" == "" ]]; then
	userDataStr=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --form "Please enter the hostname or IP of the server you wish to connect to below:\n" 25 65 16 \
	  "Username:"        1 1 "${USER}"                        1 17 40 40 \
	  "Server address:"  2 1 "server.example.tld"             2 17 40 40 \
	  "Keyfile path:"    3 1 "/home/${USER}/.ssh/id_ed25519"  3 17 40 40 \
	  3>&1 1>&2 2>&3)
	isOkay=$?
else
	userDataStr=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --extra-button --extra-label "Terminal" \
	  --form "Please enter the hostname or IP of the server you wish to connect to below:\n" 25 65 16 \
	  "Username:"        1 1 "${USER}"                        1 17 40 40 \
	  "Server address:"  2 1 "server.example.tld"             2 17 40 40 \
	  "Keyfile path:"    3 1 "/home/${USER}/.ssh/id_ed25519"  3 17 40 40 \
	  3>&1 1>&2 2>&3)
	isOkay=$?
fi
if [[ -z "${userDataStr}" ]] || [[ "${isOkay}" == "1" ]]; then
	# silently exit here - obviously the user doesn't want to progress
	clear
	exit 1
fi
if [[ "${isOkay}" == "3" ]]; then
	# if the user ent a sudoer
	if [[ "${isSudoer}" == "" ]]; then
		# alert the user
		errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
		  --msgbox "E: ${USER} is not in the sudoers file. This incident will be reported." 25 65 \
		  3>&1 1>&2 2>&3)
		clear
		exit 1
	else
		## if the user is a sudoer
		clear
		echo -ne "Performing interactive logon . . . \n"
		exec ${userShell}
		exit 0
	fi
fi


##
## process the data
readarray -t userDataArr < <(printf '%s' "${userDataStr}")


##
## if the keyfile element is unset
if [[ "${userDataArr[2]}" == "" ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You must enter a keyfile path to connect via SSH" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=1
else
	# set the var
	keyfilePath="${userDataArr[2]}"
fi
## if the host element is unset
if [[ "${userDataArr[1]}" == "" ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You must enter a server address to connect via SSH" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=1
else
	# set the var
	host="${userDataArr[1]}"
fi
## if the user element is unset
if [[ "${userDataArr[0]}" == "" ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You must enter a username to connect via SSH" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=1
else
	# set the var
	username="${userDataArr[0]}"
fi
## process isOkay
if [[ "${isOkay}" != "0" ]]; then
	# something has gone wrong
	clear
	exit 1
fi


## check the values passed are valid ones
if [[ "${host}" == "localhost" ]] || [[ "${host}" == "localhost.localnet" ]] || [[ "${host}" == "0" ]] || [[ "${host}" == "::" ]] || [[ "${host}" == "::1" ]] || [[ "${host}" == "0.0.0.0" ]] || [[ "${host}" == "127."* ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You cannot use a local address or hostname" 25 65 \
	  3>&1 1>&2 2>&3)
	clear
	exit 1
fi


## execute ssh command
clear
echo -ne "Performing interactive logon . . . \n"
exec ssh -o "LogLevel ERROR" -i "${keyfilePath}" "${username}"@"${host}"
exit 0
