#!/usr/bin/env bash


## vars
hostsList=($(grep -P "^Host ([^*]+)$" ${HOME}/.ssh/config | sed 's/Host //' | sed ':a;N;$!ba;s/\n/ /g')) # grep a list from .ssh/config
tempArr=''
for (( i=0; i<${#hostsList[@]}; i++)); do
	tempArr+=(${hostsList[$i]}) # whiptail likes a tag and description
	tempArr+=(${hostsList[$i]}) # we just want one - duplicate them
done
hostsList=(${tempArr[@]}) # copy back to hostsList
host=''


## start keychain agent
eval $(keychain --agents ssh --eval id_ed25519 --quiet >/dev/null 2>&1) # run keychain if it exists


## say hola
clear
echo "Performing interactive logon . . . "


## what are we going to use - you decide
host=$(whiptail --title "Log on to "$(hostname) --notags --menu "Please select a server from the list below:\nTo access the local terminal, press cancel instead:" 20 74 10 ${hostsList[@]} 3>&1 1>&2 2>&3) # ask for the hostname
if [[ $? != 0 ]]; then
	exec bash
	exit 0
fi

## execute ssh command
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" "${host}"
exit 0
