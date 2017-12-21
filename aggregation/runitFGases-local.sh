#!/bin/sh

sql_script="fgases-extraction-`date +%F`.sql"
rm -f $sql_script

accessfile="fgases-aggregation-db`date +%F`.accdb"
rm -f $accessfile

obligation="http://rod.eionet.europa.eu/obligations/713"

echo Grabbing files
python2 grabfiles-local.py $obligation >> $sql_script

echo Store data in MS Access
cp FGases-aggregation-db.accdb $accessfile

java -jar sqlbatch.jar $accessfile $sql_script

#copy final file to virtualbox shared folder
cp $accessfile /home/dev-gso/sf_eea/Reportnet/Dataflows/FGases/aggregation/