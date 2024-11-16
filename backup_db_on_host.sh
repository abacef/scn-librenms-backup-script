set -e 

db_container=$(docker ps --filter "name=librenms_db" --format "{{.ID}}")
docker exec $db_container mysqldump librenms -u librenms --password=$MYSQL_PASSWORD > librenms.sql
zip librenms.sql.zip librenms.sql
rm librenms.sql