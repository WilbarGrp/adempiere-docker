#!/bin/bash 
set -x #echo on

FROM_DB=$1 #SAME AS adempiere tenant name
TO_DB=$2 #SAME AS adempiere tenant name
DB_TO_RESTOR=$3 

if [ "$DB_TO_RESTOR" = "live"]

BASE_DIR=$(cd "$(dirname "$0")"; pwd)

myFileName=db-bck-$(date +%d-%m-%y).sql

#BACKUP_FILE="Tuesday_LiveDbBackup.sql.gz"
BACKUP_FILE="zwg-db.gz"

if [ "$DB_TO_RESTOR" = "live"] 
then
	$BACKUP_FILE="liveDB.gz"
fi

echo "We will restor $BACKUP_FILE"
URL="https://fs.piscinetrendium.com:7443/$BACKUP_FILE"
USER_PSSWD="mike:RoadBike401"
if [ -d "$BASE_DIR" ]
then
    if [ -f "$BACKUP_FILE" ]
    then
       echo "Backup to restor already exist we will restor from that file $BACKUP_FILE"
    else
       echo "Download from $URL"
       curl -k -u "mike:RoadBike401" -L "$URL" > "$BACKUP_FILE"
       if [ -f "$BACKUP_FILE" ]
       then
         echo "Db Backup download successful"
       else
              "Db Backup not download"
              exit
       fi
    fi
fi

#echo "backup actual db just in case ;-)"
#docker exec -t postgres132_db_1 pg_dump -U $TO_DB $TO_DB --no-owner > ./$myFileName

gunzip $BACKUP_FILE
BACKUP_FILE=${BACKUP_FILE%.gz}
docker cp $BACKUP_FILE postgres132_db_1:/tmp

docker stop $TO_DB
docker stop postgres132_db_1
docker start postgres132_db_1
docker exec -it postgres132_db_1 dropdb -U $TO_DB $TO_DB
docker exec -it postgres132_db_1 createdb -U $TO_DB $TO_DB -E unicode

docker exec -t postgres132_db_1 psql -U $TO_DB -d $TO_DB -f "/tmp/$BACKUP_FILE"
echo "ALTER SCHEMA $FROM_DB RENAME TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U $TO_DB 
echo "REASSIGN OWNED BY $FROM_DB TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U $TO_DB
docker start $TO_DB
rm $BACKUP_FILE
