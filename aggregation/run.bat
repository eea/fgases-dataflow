
rem set dumpfile="fgases-extraction.sql"
set dumpfile="ods-extraction.sql"

rem set accessfile="FGases-aggregation-db.accdb"
set accessfile="ODS-aggregation-db.accdb"

rem set obligation="http://rod.eionet.europa.eu/obligations/669"
set obligation="http://rod.eionet.europa.eu/obligations/213"

python grabfiles.py -r %obligation% > %dumpfile%
rem java  -cp .;Access_JDBC40.jar sjsql com.hxtt.sql.access.AccessDriver jdbc:access:/%accessfile% n n %dumpfile% 
java  -cp . sjsql sun.jdbc.odbc.JdbcOdbcDriver "jdbc:odbc:Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=./%accessfile%;" n n %dumpfile% 
rem java  -cp . sjsql sun.jdbc.odbc.JdbcOdbcDriver "jdbc:odbc:fgasesMDB" n n %dumpfile% 

