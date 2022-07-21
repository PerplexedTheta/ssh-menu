#!/usr/bin/env bash


## vars
sudo -n echo -n "" >/dev/null 2>&1 # do not touch
isSudoer=$? # set to 0 to enable bash for all users - $? is the default
isOkay="" # do not touch
title="Log on to "$(hostname) # change to edit menu titles
forceIntro="1" # set to 1 to show intro screen
introMsg="Unauthorised access is prohibited." # change this to modify intro text
forceHost="0" # set to 1 to force a specific hostname
host="" # set default hostname
forcePort="0" # set to 1 to force a specific port
port="22" # set default port
forceUsername="0" # set to 1 to force a specific username
username="${USER}" # dset default username


## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet >/dev/null 2>&1)


## say hola
clear
echo "Performing interactive logon . . . "
if [[ "${forceIntro}" == "1" ]]; then
	intro=$(whiptail --msgbox "${introMsg}" 7 74 --title "${title}" 3>&1 1>&2 2>&3)
	isOkay=$?
fi


## get host
if [[ "${forceHost}" != "1" ]]; then
	if [[ "${isSudoer}" != "0"  ]]; then
		host=$(whiptail --inputbox "Please enter the hostname or IP of the server you wish to connect to below:" 9 74 "${host}" --title "${title}" 3>&1 1>&2 2>&3)
		isOkay=$?
	else
		host=$(whiptail --inputbox "Please enter the hostname or IP of the server you wish to connect to below:\nTo access the local terminal, type 'bash' instead:" 10 74 "${host}" --title "${title}" 3>&1 1>&2 2>&3)
		isOkay=$?
	fi
fi
if [[ -z "${host}" || "${host}" == "exit" || "${isOkay}" != "0" ]]; then
	# silently exit here - obviously the user doesn't want to progress
	exit 1
fi
if [[ "${host}" == "localhost" ]] || [[ "${host}" == "0" ]] || [[ "${host}" == "::" ]] || [[ "${host}" == "::1" ]] || [[ "${host}" == "127.0.0."* ]] || [[ "${host}" == "0.0.0.0" ]] || [[ "${host}" == "10."* ]] || [[ "${host}" == "172.16."* ]] || [[ "${host}" == "192.168."* ]]; then
	whiptail --msgbox "You cannot use a local or private IP address or hostname. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ "${host}" == "bash" ]]; then
	if [[ "${isSudoer}" != "0" ]]; then
		whiptail --msgbox "Your user is not permitted to access a terminal session. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
		exit 1
	else
		exec bash
		exit 0
	fi
fi


## get port
if [[ "${forcePort}" != "1" ]]; then
	port=$(whiptail --inputbox "Please enter the port of the server you wish to connect to below:" 8 74 ${port} --title "${title}" 3>&1 1>&2 2>&3)
	isOkay=$?
fi
if [[ "${isOkay}" != "0" ]]; then
	exit 1
fi
if [[ -z "${port}" ]]; then
	whiptail --msgbox "You failed to provide a port number. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ -n ${port//[0-9]/} ]]; then
	whiptail --msgbox "You must provide a port between 1-65535. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi


## get username
if [[ "${forceUsername}" != "1" ]]; then
	username=$(whiptail --inputbox "Please enter the username for the server you wish to connect to below:" 8 74 "${username}" --title "Log on to "$(hostname) 3>&1 1>&2 2>&3)
	isOkay=$?
fi
if [[ "${isOkay}" != "0" ]]; then
	exit 1
fi


## produce connection string
if [[ "${username}" != "" ]]; then
	conn="${username}@${host}"
else
	conn="${host}"
fi

## execute ssh command
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" -p "${port}" "${conn}"
exit 0
