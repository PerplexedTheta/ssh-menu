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
host="" # set default hostname
keyfilePath="~/.ssh/id_ed25519" # set default keyfile
tempList=($(cat ${HOME}/.ssh/config | grep -P "^Host ([^*]+)$" | sed 's/Host //' | sed ':a;N;$!ba;s/\n/ /g')) # do not touch
hostsList=() # do not touch
username="${USER}" # set default username


##
## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet >/dev/null 2>&1) # run keychain if it exists


##
## populate hostsList
IFS=$'\n' tempList=($(sort <<<"${tempList[*]}")); unset IFS # sort the array
for (( i=0; i<${#tempList[@]}; i++)); do
	hostsList+=(${tempList[$i]}) # dialog likes a tag and description
	hostsList+=($(ssh -G "${tempList[$i]}" | awk '$1 == "hostname" { print $2 }')) # this gets the hostname of the alias
done


##
## say hola
clear
echo "Performing interactive logon . . . "
if [[ "${showIntro}" == "1" ]]; then
	intro=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "${introMsg}" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=$?
fi


##
## what are we going to use - you decide
if [[ "${isSudoer}" == ""  ]]; then
	userData=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --menu "Please select a server from the list below:\n" 25 65 17 \
	  ${hostsList[@]} \
	  3>&1 1>&2 2>&3)
	isOkay=$?
else
	userDataStr=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --extra-button --extra-label "Terminal" \
	  --menu "Please select a server from the list below:\n" 25 65 17 \
	  ${hostsList[@]} \
	  3>&1 1>&2 2>&3)
	isOkay=$?
fi
if [[ -z "${userDataStr}" ]] || [[ "${isOkay}" == "1"  ]]; then
	# silently exit here - obviously the user doesn't want to progress
	clear
	exit 1
fi
if [[ "${isOkay}" == "3"  ]]; then
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
		exec ${userShell}
		exit 0
	fi
fi


## if the host element is unset
if [[ "${userDataStr}" == "" ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You must enter a server address to connect via SSH" 25 65 \
	  3>&1 1>&2 2>&3)
	isOkay=1
else
	# set the var
	host="${userDataStr}"
fi
## process isOkay
if [[ "${isOkay}" != "0" ]]; then
	# something has gone wrong
	clear
	exit 1
fi


## check the values passed are valid ones
if [[ "${host}" == "localhost" ]] || [[ "${host}" == "localhost.localnet"  ]] || [[ "${host}" == "0" ]] || [[ "${host}" == "::" ]] || [[ "${host}" == "::1" ]] || [[ "${host}" == "0.0.0.0"  ]] || [[ "${host}" == "127."* ]]; then
	# alert the user
	errorText=$(/usr/bin/dialog --backtitle "${title}" --title "${title}" \
	  --msgbox "E: You cannot use a local address or hostname" 25 65 \
	  3>&1 1>&2 2>&3)
	clear
	exit 1
fi


## execute ssh command
clear
exec ssh -o "LogLevel ERROR" -F "/home/${USER}/.ssh/config" -i "${keyfilePath}" "${host}"
exit 0
