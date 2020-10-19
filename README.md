# User Management Bash script for Linux
General bash script which would
- Create a user
- Checkout a user
- Delete the user

## Creating the user
Provided script will check for user name correctness (if it is empty or duplicate) then it create a the user with its own:
- group
- home directory
- UID and GID
then it will configure related files and save a log for this activity

## Checking out an user
Like creating the user, the script will check if the entered user is existed and available and then it return the related data about the user. This action also save a log in `/var/log/usermanagement.log`.

## Deleting the user
This part delete the user after authenticating its existence. Deleting an user includes:
- deleting home directory
- deleting email directory
- deleting records from related configuration files
    - `/etc/passwd`
    - `/etc/shadow`
    - `/etc/group`
and finally it will save a log of this action.

>A very detailed documentation of this project is provided  in `./Documentation.pdf` in Persian to check out more about this script.
