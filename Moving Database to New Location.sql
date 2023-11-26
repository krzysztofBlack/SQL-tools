
--https://www.mssqltips.com/sqlservertip/3212/options-to-move-a-big-sql-server-database-to-a-new-drive-with-minimal-downtime/

USE [master]
GO
CREATE DATABASE [TestDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestDB', FILENAME = N'c:\SQL\TestDB.mdf' , 
 SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
( NAME = N'TestDB_1', FILENAME = N'c:\SQL\TestDB_1.ndf' , 
 SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
( NAME = N'TestDB_2', FILENAME = N'c:\SQL\TestDB_2.ndf' , 
 SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TestDB_log', FILENAME = N'c:\SQL\TestDB.ldf' ,
 SIZE = 4096KB , MAXSIZE = 2048GB , FILEGROWTH = 1024KB)
GO
ALTER DATABASE [TestDB] SET RECOVERY SIMPLE

USE TestDB
GO
IF OBJECT_ID('dbo.SampleTable', 'U') IS NOT NULL
    DROP TABLE dbo.SampleTable
GO
CREATE TABLE dbo.SampleTable
    (
      ID INT IDENTITY(1, 1) ,
      Data DATETIME PRIMARY KEY CLUSTERED ( ID )
    )
GO

use 
select MAX(id) from sampleTable

USE TestDB
GO
INSERT INTO dbo.SampleTable
        ( Data )
VALUES  ( GETDATE()
          )

GO 1000 000

set nocount on


-- Add new files
USE [master]
GO
ALTER DATABASE [TestDB]
 ADD FILE ( NAME = N'TestDB_1_New',
    FILENAME = N'E:\SQL\TestDB_1_New.ndf' ,
     SIZE = 4096KB , FILEGROWTH = 1024KB 
    ) TO FILEGROUP [PRIMARY]
GO
ALTER DATABASE [TestDB]
 ADD FILE ( NAME = N'TestDB_2_New',
    FILENAME = N'E:\SQL\TestDB_2_New.ndf' ,
     SIZE = 4096KB , FILEGROWTH = 1024KB 
    ) TO FILEGROUP [PRIMARY]
GO

USE [master]
GO
ALTER DATABASE [TestDB] MODIFY FILE ( NAME = N'TestDB', FILEGROWTH = 0)
GO
ALTER DATABASE [TestDB] MODIFY FILE ( NAME = N'TestDB_1', FILEGROWTH = 0)
GO


ALTER DATABASE [TestDB] MODIFY FILE ( NAME = N'TestDB_2', FILEGROWTH = 0)
GO

-- Move Data
-- Will be error that system data cannot be moved
USE TestDB
GO
DBCC SHRINKFILE('TestDB_1', EMPTYFILE)
GO
DBCC SHRINKFILE('TestDB_1', TRUNCATEONLY)
GO
DBCC SHRINKFILE('TestDB_2', EMPTYFILE)
GO
DBCC SHRINKFILE('TestDB_2', TRUNCATEONLY)
GO
DBCC SHRINKFILE('TestDB', EMPTYFILE)
GO
DBCC SHRINKFILE('TestDB', TRUNCATEONLY)
GO
CHECKPOINT
DBCC SHRINKFILE('TestDB_log', TRUNCATEONLY)
GO

USE master
GO
ALTER DATABASE TestDB SET OFFLINE WITH ROLLBACK IMMEDIATE

---------------------------
-- Update primary database file 
USE master
GO
ALTER DATABASE TestDB MODIFY FILE 
(
NAME = N'TestDB',
FILENAME = N'c:\SQL\TestDB.mdf'
);
ALTER DATABASE TestDB MODIFY FILE 
(
NAME = N'TestDB_log',
FILENAME = N'c:\SQL\TestDB.ldf'
);

USE master
GO
ALTER DATABASE TestDB SET ONLINE WITH ROLLBACK IMMEDIATE


-- remove old files
USE [TestDB]
GO
ALTER DATABASE [TestDB] REMOVE FILE [TestDB_1]
GO
USE [TestDB]
GO
ALTER DATABASE [TestDB] REMOVE FILE [TestDB_2]
GO

-----------------------------------------------

USE [TestDB]
GO
ALTER DATABASE [TestDB] MODIFY FILE (NAME=N'TestDB_1_New', NEWNAME=N'TestDB_1')
GO
USE [TestDB]
GO
ALTER DATABASE [TestDB] MODIFY FILE (NAME=N'TestDB_2_New', NEWNAME=N'TestDB_2')
GO

use ksx1_REST


select * from sys.database_files

BACKUP DATABASE [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest.bak' WITH FORMAT, INIT,  
NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  CHECKSUM, STATS = 10
GO

BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest1.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO

BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest2.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO


-- Differential
BACKUP DATABASE [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest_Diff.dif' WITH  DIFFERENTIAL , NOFORMAT, INIT,  
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM


BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest3.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO




USE [master]

GO


IF DB_ID('ksx1_rest_MOVE_1') IS NOT NULL
BEGIN
  ALTER DATABASE [ksx1_rest_MOVE_1] SET SINGLE_USER WITH
  ROLLBACK IMMEDIATE;

  DROP DATABASE [ksx1_rest_MOVE_1];

END

USE [master]

GO


SELECT 
  DB_NAME([database_id]) [database_name]
, [file_id]
, [type_desc] [file_type]
, [name] [logical_name]
, [physical_name]
FROM sys.[master_files]
WHERE [database_id] IN (DB_ID('ksx1_rest'), DB_ID('ksx1_rest_move'))
ORDER BY [type], DB_NAME([database_id]);


USE [master]
GO

RESTORE filelistonly FROM DISK = 'e:\sql\ksx1_rest.bak'
RESTORE Headeronly FROM DISK = 'e:\sql\ksx1_rest.bak'
RESTORE Labelonly FROM DISK = 'e:\sql\ksx1_rest.bak'
RESTORE Verifyonly FROM DISK = 'e:\sql\ksx1_rest.bak'


RESTORE DATABASE [ksx1_rest_MOVE_1] FROM DISK = 'e:\sql\ksx1_rest.bak'
WITH CHECKSUM,
MOVE 'ksx1' TO 'e:\sql\ksx1a_REST.mdf',
MOVE 'ksx1_Log' TO 'e:\sql\ksx1a_REST_log.ldf',
NORECOVERY, REPLACE, STATS = 10;

-- Restore from differential
RESTORE DATABASE [ksx1_rest_MOVE_1] FROM DISK = 'E:\SQL\ksx1_rest_Diff.dif'
WITH CHECKSUM,
NORECOVERY, REPLACE, STATS = 10;


RESTORE LOG [ksx1_rest_MOVE_1] FROM  DISK = N'E:\SQL\ksx1_rest1.trn' WITH  NORECOVERY,  NOUNLOAD, CHECKSUM, STATS = 10

RESTORE LOG [ksx1_rest_MOVE_1] FROM  DISK = N'E:\SQL\ksx1_rest2.trn' WITH  NORECOVERY,  NOUNLOAD, CHECKSUM, STATS = 10

RESTORE LOG [ksx1_rest_MOVE_1] FROM  DISK = N'E:\SQL\ksx1_rest3.trn' WITH  NORECOVERY,  NOUNLOAD, CHECKSUM, STATS = 10

RESTORE DATABASE [ksx1_rest_MOVE_1] WITH RECOVERY


USE master;  
GO  

ALTER DATABASE [ksx1_rest_MOVE] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [ksx1_rest_MOVE] MODIFY NAME = ksx1_rest_MOVE_n;
GO  
ALTER DATABASE [ksx1_rest_MOVE_n] SET MULTI_USER;
GO

----------------------------
/*
    This script will generate a "RESTORE DATABASE" command with the correct "MOVE" clause, etc.
     By: Max Vernon
*/

SET NOCOUNT ON;
DECLARE @FileListCmd            nvarchar(max);
DECLARE @RestoreCmd             nvarchar(max);
DECLARE @cmd                    nvarchar(max);
DECLARE @BackupFile             nvarchar(max);
DECLARE @DBName                 sysname;
DECLARE @DataPath               nvarchar(260);
DECLARE @LogPath                nvarchar(260);
DECLARE @Version                decimal(10,2);
DECLARE @MaxLogicalNameLength   int;
DECLARE @MoveFiles              nvarchar(max);

SET @BackupFile     = N'e:\sql\ksx1_rest.bak'; --source backup file
SET @DBName         = N'MyDB'; --target database name
SET @DataPath       = N'e:\Database\Data'; --target data path
SET @LogPath        = N'e:\Database\Log'; --target log path

/* ************************************

    modify nothing below this point.

   ************************************ */
IF RIGHT(@DataPath, 1) <> '\' SET @DataPath = @DataPath + N'\';
IF RIGHT(@LogPath, 1) <> '\' SET @LogPath = @LogPath + N'\';
SET @cmd = N'';
SET @Version = CONVERT(decimal(10,2), 
    CONVERT(varchar(10), SERVERPROPERTY('ProductMajorVersion')) 
    + '.' + 
    CONVERT(varchar(10), SERVERPROPERTY('ProductMinorVersion'))
    );
IF @Version IS NULL --use ProductVersion instead
BEGIN
    DECLARE @sv varchar(10);
    SET @sv = CONVERT(varchar(10), SERVERPROPERTY('ProductVersion'));
    SET @Version = CONVERT(decimal(10,2), LEFT(@sv, CHARINDEX(N'.', @sv) + 1));
END

IF OBJECT_ID(N'tempdb..#FileList', N'U') IS NOT NULL
BEGIN
    DROP TABLE #FileList;
END
CREATE TABLE #FileList 
(
      LogicalName               sysname             NOT NULL
    , PhysicalName              varchar(255)        NOT NULL
    , [Type]                    char(1)             NOT NULL
    , FileGroupName             sysname             NULL
    , Size                      numeric(20,0)       NOT NULL
    , MaxSize                   numeric(20,0)       NOT NULL
    , FileId                    bigint              NOT NULL
    , CreateLSN                 numeric(25,0)       NOT NULL
    , DropLSN                   numeric(25,0)       NULL
    , UniqueId                  uniqueidentifier    NOT NULL
    , ReadOnlyLSN               numeric(25,0)       NULL
    , ReadWriteLSN              numeric(25,0)       NULL
    , BackupSizeInBytes         bigint              NOT NULL
    , SourceBlockSize           int                 NOT NULL
    , FileGroupId               int                 NULL
    , LogGroupGUID              uniqueidentifier    NULL
    , DifferentialBaseLSN       numeric(25,0)       NULL
    , DifferentialBaseGUID      uniqueidentifier    NOT NULL
    , IsReadOnly                bit                 NOT NULL
    , IsPresent                 bit                 NOT NULL 
);

IF @Version >= 10.5 ALTER TABLE #FileList ADD TDEThumbprint varbinary(32) NULL;
IF @Version >= 12   ALTER TABLE #FileList ADD SnapshotURL nvarchar(360) NULL;

SET @FileListCmd = N'RESTORE FILELISTONLY FROM DISK = N''' + @BackupFile + N''';';

INSERT INTO #FileList
EXEC (@FileListCmd);
SET @MaxLogicalNameLength = COALESCE((SELECT MAX(LEN(fl.LogicalName)) FROM #FileList fl), 0);
SELECT @MoveFiles = (SELECT N', MOVE N''' + fl.LogicalName + N''' ' 
    + REPLICATE(N' ', @MaxLogicalNameLength - LEN(fl.LogicalName)) 
    + N'TO N''' + CASE WHEN fl.Type = 'L' THEN @LogPath ELSE @DataPath END 
    + @DBName + N'\' + CASE WHEN fl.FileGroupName = N'PRIMARY' THEN N'System' 
                            WHEN fl.FileGroupName IS NULL THEN N'Log' 
                            ELSE fl.FileGroupName END 
    + N'\' + fl.LogicalName + CASE WHEN fl.Type = 'L' THEN N'.log' 
                                ELSE 
                                    CASE WHEN fl.FileGroupName = N'PRIMARY' THEN N'.mdf'
                                     ELSE N'.ndf' 
                                     END 
                                END + N'''
    '
FROM #FileList fl
FOR XML PATH(''));

SET @MoveFiles = REPLACE(@MoveFiles, N'&#x0D;', N'');
SET @MoveFiles = REPLACE(@MoveFiles, char(10), char(13) + char(10));
SET @MoveFiles = LEFT(@MoveFiles, LEN(@MoveFiles) - 2);

SET @RestoreCmd = N'RESTORE DATABASE ' + @DBName + N'
FROM DISK = N''' + @BackupFile + N''' 
WITH REPLACE 
    , RECOVERY
    , STATS = 5
    ' + @MoveFiles + N';
GO;';

IF LEN(@RestoreCmd) > 4000 
BEGIN
    DECLARE @CurrentLen int;
    SET @CurrentLen = 1;
    WHILE @CurrentLen <= LEN(@RestoreCmd)
    BEGIN
        PRINT SUBSTRING(@RestoreCmd, @CurrentLen, 4000);
        SET @CurrentLen = @CurrentLen + 4000;
    END
    RAISERROR (N'Output is chunked into 4,000 char pieces - look for errant line endings!', 14, 1);
END
ELSE
BEGIN
    PRINT @RestoreCmd;
END


----------------------------------------------------------------------
--https://www.mssqltips.com/sqlservertip/1584/auto-generate-sql-server-restore-script-from-backup-files-in-a-directory/

USE Master; 
GO  
SET NOCOUNT ON 

-- 1 - Variable declaration 
DECLARE @dbName sysname 
DECLARE @backupPath NVARCHAR(500) 
DECLARE @cmd NVARCHAR(500) 
DECLARE @fileList TABLE (backupFile NVARCHAR(255)) 
DECLARE @lastFullBackup NVARCHAR(500) 
DECLARE @lastDiffBackup NVARCHAR(500) 
DECLARE @backupFile NVARCHAR(500) 

-- 2 - Initialize variables 
SET @dbName = 'ksx1_REST' 
SET @backupPath = 'e:\SQL\' 

-- 3 - get list of files 
SET @cmd = 'DIR /b "' + @backupPath + '"'

INSERT INTO @fileList(backupFile) 
EXEC master.sys.xp_cmdshell @cmd 

-- 4 - Find latest full backup 
SELECT @lastFullBackup = MAX(backupFile)  
FROM @fileList  
WHERE backupFile LIKE '%.BAK'  
   AND backupFile LIKE @dbName + '%' 

SET @cmd = 'RESTORE DATABASE [' + @dbName + '] FROM DISK = '''  
       + @backupPath + @lastFullBackup + ''' WITH NORECOVERY, REPLACE' 
PRINT @cmd 

-- 4 - Find latest diff backup 
SELECT @lastDiffBackup = MAX(backupFile)  
FROM @fileList  
WHERE backupFile LIKE '%.DIF'  
   AND backupFile LIKE @dbName + '%' 
   AND backupFile > @lastFullBackup 

-- check to make sure there is a diff backup 
IF @lastDiffBackup IS NOT NULL 
BEGIN 
   SET @cmd = 'RESTORE DATABASE [' + @dbName + '] FROM DISK = '''  
       + @backupPath + @lastDiffBackup + ''' WITH NORECOVERY' 
   PRINT @cmd 
   SET @lastFullBackup = @lastDiffBackup 
END 

-- 5 - check for log backups 
DECLARE backupFiles CURSOR FOR  
   SELECT backupFile  
   FROM @fileList 
   WHERE backupFile LIKE '%.TRN'  
   AND backupFile LIKE @dbName + '%' 
   AND backupFile > @lastFullBackup 

OPEN backupFiles  

-- Loop through all the files for the database  
FETCH NEXT FROM backupFiles INTO @backupFile  

WHILE @@FETCH_STATUS = 0  
BEGIN  
   SET @cmd = 'RESTORE LOG [' + @dbName + '] FROM DISK = '''  
       + @backupPath + @backupFile + ''' WITH NORECOVERY' 
   PRINT @cmd 
   FETCH NEXT FROM backupFiles INTO @backupFile  
END 

CLOSE backupFiles  
DEALLOCATE backupFiles  

-- 6 - put database in a useable state 
SET @cmd = 'RESTORE DATABASE [' + @dbName + '] WITH RECOVERY' 
PRINT @cmd 

print  rtrim(replace(replace(replace( CONVERT(char(20), GETDATE(),20),'-',''),':',''),' ',''))


BACKUP DATABASE [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest.bak' WITH FORMAT, INIT,  
NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  CHECKSUM, STATS = 10
GO

BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest1.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO

BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest2.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO


-- Differential
BACKUP DATABASE [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest_Diff.dif' WITH  DIFFERENTIAL , NOFORMAT, INIT,  
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM


BACKUP LOG [ksx1_REST] TO  DISK = N'E:\SQL\ksx1_rest3.trn' 
WITH FORMAT, INIT,  NAME = N'ksx1_REST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, CHECKSUM, COMPRESSION,  STATS = 10
GO


--------------------------------------------------------
--Simply the best
-- https://www.mssqltips.com/sqlservertip/1243/auto-generate-sql-server-database-restore-scripts/


SET NOCOUNT ON 

DECLARE @backup_set_id_Full INT
DECLARE @Full_Backup_Set_Date	datetime 
DECLARE @backup_set_id_Diff INT 
DECLARE @backup_set_id_Tlog INT 
DECLARE @backup_set_id_end INT
DECLARE @Last_Backup_Set_Date	datetime 
DECLARE @databaseName sysname 

SET @databasename = 'ksx1_rest'

-- Get the ID of the most recent full backup for the database
SELECT @backup_set_id_Full = MAX(backup_set_id)
FROM  msdb.dbo.backupset  
WHERE database_name = @databaseName 
	AND type = 'D' 

-- Get the ID for the most recent DIFF backup is it exists
SELECT @backup_set_id_Diff = MAX(backup_set_id)  
FROM  msdb.dbo.backupset  
WHERE database_name = @databaseName 
	AND type = 'I' 
	AND backup_set_id > (@backup_set_id_Full)

-- If no DIFF backup exists, then set the DIFF ID to the full backup ID
IF @backup_set_id_Diff IS NULL
BEGIN
	SET @backup_set_id_Diff = @backup_set_id_Full
END
ELSE
BEGIN
	-- Set the Last Backup Date to the most recent Differential
	SET @Last_Backup_Set_Date = @Full_Backup_Set_Date
END

-- Set a maximum backup set ID to make sure this is at the bottom of the list
IF @backup_set_id_end IS NULL SET @backup_set_id_end = 999999999 

-- UNION the Full backup with the Differential, with the trailing TLOG backups
SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = '''  
               + mf.physical_device_name + ''' WITH ' + 'FILE = ' + convert(varchar(10), b.position) +  ', NORECOVERY'
				as CommandSet 
FROM    msdb.dbo.backupset b, 
           msdb.dbo.backupmediafamily mf 
WHERE    b.media_set_id = mf.media_set_id 
           AND b.database_name = @databaseName 
          AND b.backup_set_id = @backup_set_id_Full 
UNION 
SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = '''  
               + mf.physical_device_name + ''' WITH ' + 'FILE = ' + convert(varchar(10), b.position) +  ', NORECOVERY' 
FROM    msdb.dbo.backupset b, 
           msdb.dbo.backupmediafamily mf 
WHERE    b.media_set_id = mf.media_set_id 
           AND b.database_name = @databaseName 
          AND b.backup_set_id = @backup_set_id_Diff 
UNION
SELECT backup_set_id, 'RESTORE LOG ' + @databaseName + ' FROM DISK = '''  
               + mf.physical_device_name + ''' WITH ' + 'FILE = ' + convert(varchar(10), b.position) +  ', NORECOVERY' 
FROM    msdb.dbo.backupset b, 
           msdb.dbo.backupmediafamily mf 
WHERE    b.media_set_id = mf.media_set_id 
           AND b.database_name = @databaseName 
          AND b.backup_set_id >= @backup_set_id_Diff AND b.backup_set_id < @backup_set_id_end 
          AND b.type = 'L'
UNION 
SELECT 999999999 AS backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' WITH RECOVERY' 
ORDER BY backup_set_id
