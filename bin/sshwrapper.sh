#!/usr/bin/env bash

## vars
sudo -n echo -n "" >/dev/null 2>&1
isSudoer=$?
title="Log on to "$(hostname)
introMsg="[W] Unauthorised access is prohibited."
introHeight=7


## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet)


## say hola
clear
echo "Performing interactive logon . . . "
INTRO=$(whiptail --msgbox "${introMsg}" ${introHeight} 74 --title "${title}" 3>&1 1>&2 2>&3)
IS_OKAY=$?


## get host
if [[ "${isSudoer}" != "0" ]]; then
	HOST=$(whiptail --inputbox "[I] Please enter the hostname or IP of the server you wish to connect to below:" 9 74 --title "${title}" 3>&1 1>&2 2>&3)
	IS_OKAY=$?
else
	HOST=$(whiptail --inputbox "[I] Please enter the hostname or IP of the server you wish to connect to below:\n[I] To access the local terminal, type 'bash' instead:" 10 74 --title "${title}" 3>&1 1>&2 2>&3)
	IS_OKAY=$?
fi

if [[ -z "${HOST}" || "${HOST}" == "exit" || "${IS_OKAY}" != "0" ]]; then
	# silently exit here - obviously the user doesn't want to progress
	exit
fi
if [[ "${HOST}" == "localhost" ]] || [[ "${HOST}" == "0" ]] || [[ "${HOST}" == "::" ]] || [[ "${HOST}" == "::1" ]] || [[ "${HOST}" == "127.0.0."* ]] || [[ "${HOST}" == "0.0.0.0" ]] || [[ "${HOST}" == "10."* ]] || [[ "${HOST}" == "172.16."* ]] || [[ "${HOST}" == "192.168."* ]]; then
	whiptail --msgbox "[E] You cannot use a local or private IP address or hostname. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ "${HOST}" == "bash" ]]; then
	if [[ "${isSudoer}" != "0" ]]; then
		whiptail --msgbox "[E] Your user is not permitted to access a terminal session. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
		exit 1
	else
		exec bash
		exit 1
	fi
fi


## get port
PORT=$(whiptail --inputbox "Please enter the port of the server you wish to connect to below:" 8 74 22 --title "${title}" 3>&1 1>&2 2>&3)
IS_OKAY=$?

if [[ "${IS_OKAY}" != "0" ]]; then
	exit
fi
if [[ -z "${PORT}" ]]; then
	whiptail --msgbox "[E] You failed to provide a port number. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi
if [[ -n ${PORT//[0-9]/} ]]; then
	whiptail --msgbox "[E] You must provide a port between 1-65535. Bye!" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi


## get username
USERNAME=$(whiptail --inputbox "Please enter the username for the server you wish to connect to below:" 8 74 ${USER} --title "Log on to "$(hostname) 3>&1 1>&2 2>&3)
IS_OKAY=$?

if [[ "${IS_OKAY}" != "0" ]]; then
	exit
fi
if [[ -z "${USERNAME}" ]]; then
	whiptail --msgbox "[E] You failed to provide a username for host '"${HOST}"'" 7 74 --title "${title}" 3>&1 1>&2 2>&3
	exit 1
fi


## execute ssh command
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" -p "${PORT}" "${USERNAME}@${HOST}"
exec exit
