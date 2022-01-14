#!/bin/bash

#
# start keychain agent
#
eval `keychain --agents ssh --eval id_ed25519 --quiet`

#
# say hello
#
echo "[I]	Welcome to the Ishukone SSH proxy server!"
echo "[W]	Unauthorised access is prohibited"
echo "[I]	To access this user's Bash terminal, use bash as the hostname below."

#
# get host
#
read -p "[I]	SSH server address: " host;

if [ -z "$host" ]; then
	echo "[E]	You failed to provide a hostname or IP address."
	exit
fi

if [[ "$host" == "localhost" ]] || [[ "$host" == "0" ]] || [[ "$host" == "::" ]] || [[ "$host" == "::1" ]] || [[ "$host" == "127.0.0."* ]] || [[ "$host" == "0.0.0.0" ]] || [[ "$host" == "10."* ]] || [[ "$host" == "172.16."* ]] || [[ "$host" == "192.168."* ]]; then
	echo "[E]	Connections to local machines cannot be performed without a valid hostname."
	exit
fi

if [[ "$host" == "bash" ]]; then
	exec bash;
	exec exit;
fi

#
# get port
#
read -p "[I]	SSH server port [22]: " port;

if [ -z "$port" ]; then
	port=22;
fi

if [[ -n ${port//[0-9]/} ]]; then
	echo "[E]	The SSH server port must be a number between 0 and 65535."
	exit
fi

#
# get username
#
read -p "[I]	SSH server username [$USER]: " username;

if [ -z "$username" ]; then
	username=$USER;
fi

#
# execute ssh command
#
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" -p "$port" "$username@$host";
exec exit;
