#!/usr/bin/env bash

## find out if we're a sudoer
sudo -n echo -n "" >/dev/null 2>&1
isSudoer=$?


## start keychain agent
eval `keychain --agents ssh --eval id_ed25519 --quiet`


## say hello
echo "[W]	Unauthorised access is prohibited"
if [[ "${isSudoer}" == "0" ]]; then
	echo "[I]	Type 'bash' below to access a terminal session."
fi
echo "[I]	Type 'exit' below to quit this SSH session."


## get host
read -p "[I]	SSH server address: " HOST

if [[ -z "${HOST}" ]]; then
	echo "[E]	You failed to provide a hostname or IP address."
	exit 1
fi
if [[ "${HOST}" == "localhost" ]] || [[ "${HOST}" == "0" ]] || [[ "${HOST}" == "::" ]] || [[ "${HOST}" == "::1" ]] || [[ "${HOST}" == "127.0.0."* ]] || [[ "${HOST}" == "0.0.0.0" ]] || [[ "${HOST}" == "10."* ]] || [[ "${HOST}" == "172.16."* ]] || [[ "${HOST}" == "192.168."* ]]; then
	echo "[E]	Connections to local machines cannot be performed without a valid hostname."
	exit 1
fi
if [[ "${isSudoer}" == "0" && "${HOST}" == "bash" ]]; then
	exec bash
	exit 1
fi
if [[ "${HOST}" == "exit" ]]; then
	exit
fi


## get port
read -p "[I]	SSH server port [22]: " PORT

if [[ -z "${PORT}" ]]; then
	PORT=22
fi
if [[ -n ${PORT//[0-9]/} ]]; then
	echo "[E]	The SSH server port must be a number between 0 and 65535."
	exit
fi

## get username
read -p "[I]	SSH server username [$USER]: " USERNAME

if [[ -z "${USERNAME}" ]]; then
	USERNAME=$USER
fi

#
# execute ssh command
#
exec ssh -o "LogLevel ERROR" -F "${HOME}/.ssh/config" -p "${PORT}" "${USERNAME}@${HOST}"
exec exit
