if (!$args[0]){
    Write-Output "Specify the Db/admp tenant to backup"
    exit 1
}
$db=$args[0]
$prefix= $args[0]
if ($args[1]){
    $prefix = $args[0] + "_" + $args[1] + "_"   
}
$myFileName= $prefix + "-bck-" + (Get-Date -UFormat "%d-%m-%y") + ".sql"

Write-Output "create the backup "
docker exec -i postgres132_db_1 pg_dump -U $db $db --no-owner -Z 9 > $myFileName
Write-Output "copy the backup to the TppNas02"
scp $myFileName root@11.95.21.8:/var/www/filleserver
