
ODS and F-Gases data aggregation tool

Setup:
 1. Make a tmp directory and ensure that the script has write-permission in it
 2. Create a file called smb.auth, which contains the three lines:
            username=<user>
            password=<password>
            domain=<domain>

Aggregation process:
 1. Downloads valid XML files from released envelopes in BDR
 2. Converts the XML files into SQL INSERT statements using XSLs
 3. Executes SQL INSERT statements in MS Access database, using HXTT jdbc driver and sjsql.class
 4. Uploads the resulting MS Access file to some network drive available to ETCs
 5. ETC will use BDR-aggregation-frontend.accdb to insert the data into their databases

How-to run the tool: 
 1. Configure BDR accounts in accounts.conf
 2. Copy the HXXT driver jar into the same directory or configure -cp in "runODS" or "runitFGases"
 3. Configure output file names "runitODS" or "runitFGases" and execute the scripts for aggregating ODS/FGases data
