use [master];
GO
USE [master]
GO
ALTER DATABASE [ksx1_clone_c] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT
GO

AUTO_UPDATE_STATISTICS_ASYNC

USE master
GO
DECLARE @kill varchar(max) = '';
SELECT @kill = @kill + 'KILL ' + CONVERT(varchar(10), spid) + '; '
FROM master..sysprocesses 
WHERE spid > 50 AND dbid = DB_ID('ksx1_clone_c')

PRINT @KILL
EXEC(@kill);


GO
SET DEADLOCK_PRIORITY HIGH
ALTER DATABASE ksx1_clone_c SET MULTI_USER WITH NO_WAIT
ALTER DATABASE ksx1_clone_c SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO
