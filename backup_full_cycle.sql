USE KSX1

BACKUP DATABASE [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX1_file.bac' WITH NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM
GO

/*
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'ksx' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'ksx' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''ksx'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX_file.bac' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
*/

BACKUP DATABASE [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX1_file_d.bac' 
WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10

BACKUP LOG [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX_log1.bac' WITH NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO

BACKUP LOG [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX_log2.bac' WITH NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO

BACKUP LOG [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX_log3.bac' WITH NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO

--

--SELECT * INTO DBO.T1C_COPY FROM [dbo].[t1c]

BACKUP LOG [ksx1] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksX_log4_PODIF.bac' WITH NOFORMAT, NOINIT,  NAME = N'ksx-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO
