#!/bin/bash
if [ -z "$1" ];
then
    echo "Specify the Db/admp tenant to backup"
    exit 1
fi
db=$1
myFileName=$db"-bck-"$(date +%A).sql.tar.gz
echo $myFileName

echo "create the backup "
docker exec -i postgres132_db_1 pg_dump -U $db $db --no-owner -Z 9 > $myFileName
echo "copy the backup to the TppNas02"
scp $myFileName root@11.95.21.8:/var/www/filleserver
