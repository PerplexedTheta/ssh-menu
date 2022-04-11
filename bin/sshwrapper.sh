#!/usr/bin/env bash

## vars
sudo -n echo -n "" >/dev/null 2>&1
isSudoer=$?
title="Log on to "$(hostname)


## start keychain agent
eval `keychain --agents ssh --eval id_ed25519 --quiet`


## say hola
echo "Performing interactive logon . . . "
if [[ "${isSudoer}" != "0" ]]; then
	whiptail --msgbox "[W] Unauthorised access is prohibited.\n[I] Type 'exit' in the prompt to quit this SSH session." 8 78 --title "${title}" 3>&1 1>&2 2>&3
	isOkay=$?
else
	whiptail --msgbox "[W] Unauthorised access is prohibited.\n[I] Type 'bash' in the prompt to access a terminal session.\n[I] Type 'exit' in the prompt to quit this SSH session." 9 78 --title "${title}" 3>&1 1>&2 2>&3
	isOkay=$?
fi


## get host
HOST=$(whiptail --inputbox "Please enter the hostname or IP of the server you wish to connect to below:" 10 78 --title "${title}" 3>&1 1>&2 2>&3)
isOkay=$?

if [[ -z "${HOST}" || "${isOkay}" != "0" ]]; then
	whiptail --msgbox "[E] You failed to provide a hostname or IP address. Bye!" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ "${HOST}" == "localhost" ]] || [[ "${HOST}" == "0" ]] || [[ "${HOST}" == "::" ]] || [[ "${HOST}" == "::1" ]] || [[ "${HOST}" == "127.0.0."* ]] || [[ "${HOST}" == "0.0.0.0" ]] || [[ "${HOST}" == "10."* ]] || [[ "${HOST}" == "172.16."* ]] || [[ "${HOST}" == "192.168."* ]]; then
	whiptail --msgbox "[E] You cannot use a local or private IP address or hostname. Bye!" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ "${isSudoer}" != "0" && "${HOST}" == "bash" ]]; then
	whiptail --msgbox "[E] Your user is not permitted to access a terminal session. Bye!" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
elif [[ "${isSudoer}" == "0" && "${HOST}" == "bash" ]]; then
	exec bash
	exit 1
fi
if [[ "${HOST}" == "exit" ]]; then
	exit
fi


## get port
PORT=$(whiptail --inputbox "Please enter the port of the server you wish to connect to below:" 7 78 22 --title "${title}" 3>&1 1>&2 2>&3)
isOkay=$?

if [[ -z "${PORT}" || "${isOkay}" != "0" ]]; then
	whiptail --msgbox "[E] You failed to provide a port number. Bye!" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ -n ${PORT//[0-9]/} ]]; then
	whiptail --msgbox "[E] You must provide a port between 1-65535. Bye!" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi


## get username
USERNAME=$(whiptail --inputbox "Please enter the username for the server you wish to connect to below:" 7 78 ${USER} --title "Log on to "$(hostname) 3>&1 1>&2 2>&3)
isOkay=$?

if [[ -z "${USERNAME}" || "${isOkay}" != "0" ]]; then
	whiptail --msgbox "[E] You failed to provide a username for host '"${HOST}"'" 7 78 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi


## execute ssh command
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" -p "${PORT}" "${USERNAME}@${HOST}"
exec exit
