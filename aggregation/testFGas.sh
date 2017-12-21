#!/bin/sh

dumpfile="output.sql"
#rm -f $dumpfile

accessfile="fgases-aggregation-db`date +%F`.accdb"
rm -f $accessfile

obligation="http://rod.eionet.europa.eu/obligations/713"

#echo Grabbing files 
#python grabfiles.py $obligation -r >> $dumpfile

echo Store data in MS Access

cp FGases-aggregation-db.accdb $accessfile
java -cp .:Access_JDBC40.jar sjsql com.hxtt.sql.access.AccessDriver jdbc:access:/$accessfile n n $dumpfile --ignore-nodata


# Copy file to network drive
#smbclient '//clu2data/ccbr$' -A smb.auth -W eea <<EoF
#cd "/F-gases/ETC ACM working area"
#put $accessfile
#EoF

#TODO copy file to network drive
#scp -q $&accessfile

#cleanup
#rm $dumpfile
#rm $accessfile
