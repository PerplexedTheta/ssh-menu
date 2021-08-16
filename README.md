# ssh-wrapper
Just a quick and dirty login wrapper for an SSH gateway server 

## Do this
1.	Create two users - login and admin. Only admin should have sudo (passwordless if you use ssh keys) access.
2.	Copy/clone the contents of bin to /usr/bin.
3.	Chown the admin-shell.sh script to the admin user and chmod it to 0700.
4.	Edit /etc/passwd and set the login shell of the login user to /usr/bin/sshwrapper.sh
5.	Edit /etc/passwd and set the login shell of the admin user to /usr/bin/admin-shell.sh
6. **Before** logging out, open a new ssh session and test both users. The admin should be able to access bash successfully with option 2.
7. Done!
