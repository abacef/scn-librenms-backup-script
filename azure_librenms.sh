set -e

backup_folder=./$(date +%s)
mkdir $backup_folder

host=othello@10.0.1.12

# backup the DB
ssh $host 'sudo mysqldump librenms -u root --password=password > librenms.sql && zip librenms.sql.zip librenms.sql && rm librenms.sql'
scp $host:/home/othello/librenms.sql.zip $backup_folder/librenms.sql.zip
ssh $host 'rm /home/othello/librenms.sql.zip'

# backup the RRD files (graph data)
ssh $host 'cd /opt/librenms && sudo zip -q -r rrd.zip rrd'
scp $host:/opt/librenms/rrd.zip $backup_folder/rrd.zip
ssh $host 'sudo rm /opt/librenms/rrd.zip'

# delete the oldest backup since this one completed sucessfully
if [ "$(ls -A)" != "" ]; then
    # Sort the items alphabetically
    sorted_items=$(ls | sort)
    
    # There should be more than 2 items, the one that was just backed up and this script
    if [ $(wc -l < <(echo "$sorted_items")) -ge 2 ]; then
        # Delete the first item
        rm -r "$(echo "$sorted_items" | head -n 1)"
    fi
fi