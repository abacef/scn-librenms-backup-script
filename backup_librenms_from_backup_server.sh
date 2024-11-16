set -e

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "set the MYSQL_PASSWORD env var in order to back up the database"
    exit 1
fi

backup_folder=./$(date +%s)
mkdir $backup_folder

host=root@172.16.20.161

echo "backing up the db"
backup_db_script=backup_db_on_host.sh
scp $backup_db_script $host:/$backup_db_script
ssh $host "MYSQL_PASSWORD=\"$MYSQL_PASSWORD\" ash /$backup_db_script"
ssh $host "rm /$backup_db_script"
scp $host:/root/librenms.sql.zip $backup_folder
ssh $host "rm /root/librenms.sql.zip"

echo "backing up the RRD files (graph data)"
ssh $host 'zip -q -r /root/rrd.zip /root/librenms_deployment3/compose/librenms/rrd'
scp $host:/root/rrd.zip $backup_folder/rrd.zip
ssh $host 'rm /root/rrd.zip'

# delete the oldest backup since this one completed sucessfully
sorted_dirs=$(ls -d */ | sed 's#/##' | sort)
if [ "$sorted_dirs" != "" ]; then
    # There should be more than 2 items, the one that was just backed up and this script
    if [ $(echo "$sorted_dirs" | wc -l) -ge 2 ]; then
        # Delete the first item
        rm -r $(echo "$sorted_dirs" | head -n 1)
    fi
fi