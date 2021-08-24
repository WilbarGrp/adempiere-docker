if (($args.count) -le 1){
    Write-Output "********************You need to pass 3 Argument ... `n********** ex: restorToDb.ps1 From_Db To_Db"
    exit 1
}

$FROM_DB=$args[0] #SAME AS adempiere tenant name
$TO_DB=$args[1] #SAME AS adempiere tenant name
$fileToRestor=$args[2]

$BASE_DIR=Get-Location


$myFileName="db-bck-" + (Get-Date -UFormat "%d-%m-%y") + ".sql"

# Write-Output "backup actual db just in case ;-)"
# docker exec -t postgres132_db_1 pg_dump -U $TO_DB $TO_DB --no-owner > ./$myFileName

docker stop $TO_DB
docker stop postgres132_db_1
docker start postgres132_db_1
docker exec -it postgres132_db_1 dropdb -U $TO_DB $TO_DB
docker exec -it postgres132_db_1 createdb -U $TO_DB $TO_DB -E unicode
docker cp $fileToRestor postgres132_db_1:/tmp
docker exec postgres132_db_1 psql -U $TO_DB -d $TO_DB -f "/tmp/$fileToRestor"
Write-Output "ALTER SCHEMA $FROM_DB RENAME TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U $TO_DB 
Write-Output "REASSIGN OWNED BY $FROM_DB TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U @TO_DB 

docker start $TO_DB

