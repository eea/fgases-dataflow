rem @echo off
rem ------
rem Batch file to run SQL queries in MS-Access database.
rem ------
echo "Converting SQL output to intermediate aggregation database"
SETLOCAL ENABLEDELAYEDEXPANSION
set sqlfile=input.sql
set templatefile=FGases-aggregation-db.accdb
set accessfile=fgases-test2.accdb

echo INSERT INTO data_companies (company_id, VAT_no, status, portal_registration_date) VALUES ('10123', 'GR123', 'VALID', '2015-12-24T00:00:00') >> %sqlfile%
echo INSERT INTO data_company_contacts (company_id, UserName) VALUES ('10123', 'company1') >> %sqlfile%
echo INSERT INTO data_companies (company_id, VAT_no, status, portal_registration_date) VALUES ('10321', 'GR321', 'VALID', '2015-12-26T00:00:00') >> %sqlfile%
echo INSERT INTO data_company_contacts (company_id, UserName) VALUES ('10321', 'company2') >> %sqlfile%
echo INSERT INTO data_companies (company_id, VAT_no, status, portal_registration_date) VALUES ('1111', 'VAT23424', 'INVALID', '') >> %sqlfile%
echo INSERT INTO data_company_contacts (company_id, UserName) VALUES ('1111', 'company3') >> %sqlfile%

set /a lines=0
for /f %%i in ('type "%sqlfile%"^|find "" /v /c') do set /a lines=%%i
rem ------
rem Convert SQL statements to accdb MS-access database using the hxtt access driver
rem ------
del %accessfile%
copy %templatefile% %accessfile%

rem java -cp .\;Access_JDBC40.jar sjsql com.hxtt.sql.access.AccessDriver jdbc:access:/%accessfile% n n %sqlfile% --ignore-nodata
for /l %%L in (1, 45, %lines%) do (
    java -cp .\;Access_JDBC40.jar sjsql com.hxtt.sql.access.AccessDriver jdbc:access:/%accessfile% n n %sqlfile% --ignore-nodata --start %%L --lines 45
)
echo "Conversion complete"