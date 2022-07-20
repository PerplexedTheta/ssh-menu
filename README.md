# ssh-wrapper
Just a quick and dirty login wrapper for an SSH gateway server 

## Do this
1.	Create a login user, and generate an (Ed25519) SSH key for them.
2.	Copy/clone the contents of bin to /usr/bin.
3.	Edit /etc/passwd and set the login shell of the login user to /usr/bin/ssh-user-shell.sh
4.	**Before** logging out, open a new ssh session and test the new user. The new user should be able to access bash by typing 'bash'.
5.	By default, only sudoers can access bash. If you want everyone to, set the variable isSudoer to "1".
6.	Done!
