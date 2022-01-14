# ssh-wrapper
Just a quick and dirty login wrapper for an SSH gateway server 

## Do this
1.	Create a login user, and generate an (Ed25519) SSH key for them.
2.	Copy/clone the contents of bin to /usr/bin.
3.	Edit /etc/passwd and set the login shell of the login user to /usr/bin/ssh-user-shell.sh
4. **Before** logging out, open a new ssh session and test the new user. The new user should be able to access bash by typing 'bash'.
5. Optionally, if you don't want the new user to access bash, comment out L13 and L30-L33.
6. Done!
