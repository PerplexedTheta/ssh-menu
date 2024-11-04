# ssh-menu
Just a quick and dirty login wrapper for an SSH gateway server 

## Do this
1.  Run `sudo apt install libcurses-ui-perl` to get the necessary cpan modules.
1.	Create a login user, and generate an (Ed25519) SSH key for them.
2.	Copy/clone the contents of bin/ to /usr/local/bin/.
3.	Edit /etc/passwd and set the login shell of the login user to /usr/local/bin/ssh-user-shell.sh
4.	**Before** logging out, open a new ssh session and test the new user. The new user should be able to access bash by pressing [t].
6.	Done!
