#!/usr/bin/env bash

#
# pass off to sshwrapper.sh
clear
echo -ne "Performing interactive logon . . . \n"
exec /usr/bin/sshwrapper.sh
exit 0
