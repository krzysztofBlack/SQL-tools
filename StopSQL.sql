

-- Net start and stop

--Named instance
net start "SQL SERVER (SQL2022)"
net stop "SQL SERVER (SQL2022)"

-- ma byc small letters
net stop mssql$SQL2022
net start mssql$SQL2022

-- default instance
net start MSSQLSERVER /f /m
net start SQLSERVERAGENT

-- when starting in sql in single mode sql agent must be stopped !!!
net start SQLAgent$SQL2022
net stop SQLAgent$SQL2022


net start "SQL Server (MSSQLSERVER)" /m"Microsoft SQL Server Management Studio - Query"
net start "SQL Server (SQL2022)" /m"Microsoft SQL Server Management Studio - Query"

If you have a default instance, use MSSQLSERVER without an instance name.
SQLCMD mustbe uppercase

net start MSSQLSERVER /f /mSQLCMD

net start mssql$SQL2022 /f /mSQLCMD

USE MASTER

CREATE LOGIN [tamagotchi] WITH PASSWORD=N'beksa12', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
;
ALTER SERVER ROLE [sysadmin] ADD MEMBER [tamagotchi];

CREATE LOGIN [DESKTOP-HN8MK56\krzys] FROM WINDOWS;
ALTER SERVER ROLE sysadmin ADD MEMBER [DESKTOP-HN8MK56\krzys];


-- Uwaga! Łączy sie, wykonuje i wychodzi z sqlcmd!
sqlcmd.exe -E -S DESKTOP-HN8MK56\SQL2022 -Q "CREATE LOGIN [tamagotchi_1] WITH PASSWORD=N'beksa12', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF; ALTER SERVER ROLE [sysadmin] ADD MEMBER [tamagotchi_1];"

-- Trusted connection
sqlcmd -S DESKTOP-HN8MK56\SQL2022 -E

-- z haslem
sqlcmd -S DESKTOP-HN8MK56\SQL2022 -U tamagotchi_1 -P beksa12 -d master

-- lepiej bez hasla i wtedy zapyta
sqlcmd -S DESKTOP-HN8MK56\SQL2022 -U tamagotchi_1 -d master

albo SET SQLCMDPASSWORD= beksa12



select suser_name()
go
shutdown
go

SP_DATABASES

net start sqlbrowser

-- INTERACTIVE
pip install mssql-cli

$ mssql-cli -S DESKTOP-HN8MK56\SQL2022 -E -d master


SET SQLCMDPASSWORD= p@a$$w0rd


SELECT 
	SERVICENAME, STARTUP_TYPE_DESC, STATUS_DESC,
        LAST_STARTUP_TIME,SERVICE_ACCOUNT,
        IS_CLUSTERED ,CLUSTER_NODENAME 
FROM SYS.DM_SERVER_SERVICES

-- show if service is running
sc query mssql$SQL2022


checkpoint





