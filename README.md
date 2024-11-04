# ssh-menu
Just a quick and dirty login wrapper for an SSH gateway server 

## Features
*   Written entirely in Curses::UI / Perl
*   Fast, secure, and light-weight
*   Mouse support
*   Less-like search-forward and search-backward supported
*   Works in any terminal down to 80x25 (or smaller with help file disabled)
*   Fully configurable – see lines 10-20 for available options

## Installation instructions
1.  Run `sudo apt install libcurses-ui-perl` to get the necessary cpan modules.
2.	Create a login user, and add your SSH pubkey to their authorized_keys. Make sure you can login.
3.	Copy/clone the contents of bin/ to /usr/local/bin/.
4.	Edit /etc/passwd and set the login shell of the login user to /usr/local/bin/ssh-user-shell.sh
5.	**Before** logging out, open a new ssh session and test the new user. The new user should be able to access a help screen by pressing [h].
6.	Done!
