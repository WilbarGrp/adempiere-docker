if (!$args[0]){
    Write-Output "Specify the Db/admp tenant to backup"
    exit 1
}
$db=$args[0]

$myFileName= $args[0] + "-bck-" + (Get-Date -UFormat "%d-%m-%y") + ".sql"

Write-Output "create the backup "
docker exec -i postgres132_db_1 pg_dump -U $db $db --no-owner -Z 9 > $myFileName
Write-Output "copy the backup to the TppNas02"
scp $myFileName root@11.95.21.8:/var/www/filleserver
