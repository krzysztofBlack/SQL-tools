use ksx

use ksx1_clone

--BACKUP DATABASE [master] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\master.bak' WITH NOFORMAT, NOINIT,  
--NAME = N'master-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM

ALTER DATABASE [ksx1_clone_c] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT

-- Before settiing single use always set async OFF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
ALTER DATABASE [ksx1_clone_c] SET AUTO_UPDATE_STATISTICS_ASYNC Off WITH NO_WAIT


USE master;  
GO
-- You need to be in master when renaming database


ALTER DATABASE ksx1_clone SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE ksx1_clone MODIFY NAME = ksx1_clone_c;
GO  
ALTER DATABASE ksx1_clone_c SET MULTI_USER;
GO

ALTER DATABASE ksx1_clone_c SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- check who use it in single mode next kill it
SELECT request_session_id FROM sys.dm_tran_locks 
WHERE resource_database_id = DB_ID('ksx1_clone_c')

-----------------------------
-- Last resort 
USE master
GO
DECLARE @kill varchar(max) = '';
SELECT @kill = @kill + 'KILL ' + CONVERT(varchar(10), spid) + '; '
FROM master..sysprocesses 
WHERE spid > 50 AND dbid = DB_ID('ksx1_clone_c')

print 'Killing sessions'
print @kill
--EXEC(@kill);


GO
SET DEADLOCK_PRIORITY HIGH
ALTER DATABASE ksx1_clone_c SET MULTI_USER WITH NO_WAIT
ALTER DATABASE ksx1_clone_c SET MULTI_USER WITH ROLLBACK IMMEDIATE

ALTER DATABASE ksx1_clone_c SET single_USER WITH ROLLBACK IMMEDIATE

GO
---------------------------------------



select * from sys.databases where name ='ksx1_clone_c'


/* Change Logical File Names */
ALTER DATABASE [ksx1_clone_c] MODIFY FILE (NAME=N'ksx1', NEWNAME=N'ksx1A')
GO

ALTER DATABASE [ksx1_clone_c] MODIFY FILE (NAME=N'ksx1_log', NEWNAME=N'ksx1A_log')
GO


--ALTER DATABASE [ksx]  REMOVE FILE [ks_log1]
--GO
ALTER DATABASE [ksx] ADD LOG FILE ( NAME = N'ks_log1', FILENAME = N'C:\SQL\MSSQL15.SQL1\MSSQL\DATA\L1\ksx_log1.ldf' , SIZE = 262144KB , FILEGROWTH = 65536KB )
--GO

ALTER DATABASE [ksx] MODIFY FILE ( NAME = N'ks_log1', SIZE = 1324MB )
GO

DBCC SHRINKFILE (ks_log1, 256);  
GO  

DBCC SHRINKFILE (ks_log1, emptyfile);  
GO  


-- Remove the data file from the database.  
ALTER DATABASE AdventureWorks2012  
REMOVE FILE Test1data;  
GO  

use ksx1_clone_c

select size*8/1024 as SizeMB,* from sys.database_files
 
 select @@VERSION


select count(*) from t1

select * into t1a
from t1 



alter table dbo.t1a 
  add id1 int not null default 2 with values
-- ( online =on )

select max(col1)  from t1a

select max(col1)  from t1
select top 5 * from t1a

sp_spaceused N'dbo.t1a'



begin transaction

set lock_timeout 5000

ALTER TABLE dbo.t1a ALTER COLUMN id2 int

rollback

commit



ALTER TABLE dbo.t1a ALTER COLUMN col_x char(5) 

--with (online=on)



ALTER TABLE dbo.t1a ALTER COLUMN id2 bigint

with (online=on)

ALTER TABLE dbo.t1a ALTER COLUMN id2 varchar(10)
with (online=on)

ALTER TABLE dbo.t1a ALTER COLUMN x1 varchar(max)
with (online=on)

ALTER TABLE dbo.t1a ALTER COLUMN x1t varchar(max)
with (online=on)


ALTER TABLE [dbo].[t1a] DROP CONSTRAINT [DF__t1a__x1__17036CC0]
GO


update dbo.t1a
with (tablock)
set id1 = 2*col1



alter table dbo.t1a 
  add x1t text not null default '223' with values

alter table dbo.t1a 
  add x2 char(5) not null default '100' with values

alter table dbo.t1a 
  add id2 int not null constraint id2_1 default 2 with values

alter table dbo.t1a 
  add id2 int not null constraint id2_1 default 2 with values


sp_spaceUsed t1a

sp_help t1a

set statistics io on
use ksx
