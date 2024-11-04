#!/usr/bin/env bash

#
# pass off to sshwrapper.sh
echo -ne "Performing interactive logon . . . \n"
exec /usr/local/bin/ssh-menu
exit 0
