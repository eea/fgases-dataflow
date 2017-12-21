#!/bin/sh

sql_script="ods-extraction-`date +%F`.sql"
rm -f $sql_script

accessfile="ods-aggregation-db`date +%F`.accdb"
rm -f $accessfile

obligation="http://rod.eionet.europa.eu/obligations/213"

echo Grabbing files 
python2 grabfiles-local.py $obligation >> $sql_script

echo Store data in MS Access
cp ODS-aggregation-db.accdb $accessfile

java -jar sqlbatch.jar $accessfile $sql_script
# Copy file to network drive
#smbclient '//clu2data/ccbr$' -A smb.auth -W eea <<EoF
#cd "/ODS/ETC ACM working area"
#put $accessfile
#EoF

#scp -q $&accessfile

#cleanup
#rm $sql_script
#rm $accessfile

#copy final file to virtualbox shared folder
cp $accessfile /home/dev-gso/sf_eea/Reportnet/Dataflows/FGases/aggregation/