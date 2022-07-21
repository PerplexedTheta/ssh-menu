#!/usr/bin/env bash


## vars
sudo -n echo -n "" >/dev/null 2>&1 # do not touch
isSudoer=$? # set to 0 to enable bash for all users - $? is the default
isOkay="" # do not touch
hostsList=($(grep -P "^Host ([^*]+)$" ${HOME}/.ssh/config | sed 's/Host //' | sed ':a;N;$!ba;s/\n/ /g')) # do not touch
tempArr='' # do not touch
for (( i=0; i<${#hostsList[@]}; i++)); do
	tempArr+=(${hostsList[$i]}) # whiptail likes a tag and description
	tempArr+=(${hostsList[$i]}) # we just want one - duplicate them
done
if [[ "${isSudoer}" != "0"  ]]; then
	continue
else
	tempArr+=("bash")
	tempArr+=("bash")
fi
hostsList=(${tempArr[@]}) # do not touch
host='' # do not touch


## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet >/dev/null 2>&1) # run keychain if it exists


## say hola
clear
echo "Performing interactive logon . . . "


## what are we going to use - you decide
if [[ "${isSudoer}" != "0"  ]]; then
	host=$(whiptail --title "Log on to "$(hostname) --notags --menu "Please select a server from the list below:" 19 74 10 ${hostsList[@]} 3>&1 1>&2 2>&3) # ask for the hostname
	isOkay=$?
else
	host=$(whiptail --title "Log on to "$(hostname) --notags --menu "Please select a server from the list below:\nTo access the local terminal, pick 'bash' instead:" 20 74 10 ${hostsList[@]} 3>&1 1>&2 2>&3) # ask for the hostname
	isOkay=$?
fi
if [[ -z "${host}" || "${host}" == "exit" || "${isOkay}" != "0" ]]; then
	# silently exit here - obviously the user doesn't want to progress
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


## execute ssh command
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" "${host}"
exit 0
