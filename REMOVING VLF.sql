use ksx
dbcc loginfo

-- Show DB Atributes
select * from sys.database_files

USE [master]
GO



GO
ALTER DATABASE [ksx] MODIFY FILE ( NAME = N'ksx_log', MAXSIZE = 10000MB , FILEGROWTH = 1000MB )
GO

SELECT name, physical_name,*
FROM sys.master_files
WHERE database_id = DB_ID('ksx');
GO

SELECT *
FROM sys.dm_os_performance_counters 
WHERE counter_name='Percent Log Used'


DBCC SQLPERF(logspace)
SELECT name, log_reuse_wait_desc FROM sys.databases

BACKUP LOG [ksx] TO  DISK = N'C:\SQL\MSSQL15.SQL1\MSSQL\Backup\ksxLog2',  DISK = N'NUL:' WITH NOFORMAT, NOINIT,  NAME = N'log',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO

DBCC SHRINKFILE (N'ksx_log' , 0, TRUNCATEONLY)
GO

SELECT 6400*128/1024

DBCC SHRINKFILE (N'ksx_log' , 64)
GO
DBCC SQLPERF(LOGSPACE) --Optional
DBCC LOGINFO --Optional 

SELECT name ,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB
FROM sys.database_files;


CHECKPOINT
DBCC DROPCLEANBUFFERS 
DBCC FREEPROCCACHE

--VLF 126
-- 48
--12



;WITH cte_vlf AS (
SELECT ROW_NUMBER() OVER(ORDER BY vlf_begin_offset) AS vlfid, DB_NAME(database_id) AS [Database Name], vlf_sequence_number, vlf_active, vlf_begin_offset, vlf_size_mb
	FROM sys.dm_db_log_info(DEFAULT)),
cte_vlf_cnt AS (SELECT [Database Name], COUNT(vlf_sequence_number) AS vlf_count,
	(SELECT COUNT(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 0) AS vlf_count_inactive,
	(SELECT COUNT(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS vlf_count_active,
	(SELECT MIN(vlfid) FROM cte_vlf WHERE vlf_active = 1) AS ordinal_min_vlf_active,
	(SELECT MIN(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS min_vlf_active,
	(SELECT MAX(vlfid) FROM cte_vlf WHERE vlf_active = 1) AS ordinal_max_vlf_active,
	(SELECT MAX(vlf_sequence_number) FROM cte_vlf WHERE vlf_active = 1) AS max_vlf_active
	FROM cte_vlf
	GROUP BY [Database Name])
SELECT [Database Name], vlf_count, min_vlf_active, ordinal_min_vlf_active, max_vlf_active, ordinal_max_vlf_active,
((ordinal_min_vlf_active-1)*100.00/vlf_count) AS free_log_pct_before_active_log,
((ordinal_max_vlf_active-(ordinal_min_vlf_active-1))*100.00/vlf_count) AS active_log_pct,
((vlf_count-ordinal_max_vlf_active)*100.00/vlf_count) AS free_log_pct_after_active_log
FROM cte_vlf_cnt
GO