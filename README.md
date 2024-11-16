# scn-librenms-backup-script

Running `backup_librenms_from_backup_server.sh` should back up the librenms install that was installed and switched over to the current source of truth of librenms on Nov 15 2024

Prereqs are that you put your ssh key of the server you are running this on, on the host running librenms

You also need to pass the password in as an env var to the script as `MYSQL_PASSWORD`. This password should be in our password storage
