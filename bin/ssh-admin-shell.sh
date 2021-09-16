#!/bin/bash

#
# offer choice
echo ""
echo "[I]	Please chose an option from below: "
echo ""
echo "[1]	Enter an SSH session to another machine"
echo "[2]	Enter a bash session to administer this machine"

#
# read choice
echo ""
echo -n "Input choice: "
read choice

#
# logic
echo ""
if [[ "$choice" == "1" ]] || [[ "$choice" == "2" ]]; then
	if [[ "$choice" == "1" ]]; then
		exec /usr/bin/sshwrapper.sh
	elif [[ "$choice" == "2" ]]; then
		exec /bin/bash
	fi
else
	echo "[E]	You chose an invalid option! Goodbye"
	exit
fi

#
# goodbye
echo ""
exec exit