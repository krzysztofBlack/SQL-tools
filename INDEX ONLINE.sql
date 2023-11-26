use ksx

--SELECT name AS 'Database Name', log_backup_time AS 'last log backup time' 
--FROM sys.databases AS s
--CROSS APPLY sys.dm_db_log_stats(s.database_id); 

/*

PS C:\Users\krzys> $serverName = $env:COMPUTERNAME
>> $Counters = @(
>>     ("\\$serverName" + "\Process(sqlservr*)\% User Time"), ("\\$serverName" + "\Process(sqlservr*)\% Privileged Time")
>> )
>> Get-Counter -Counter $Counters -MaxSamples 30 | ForEach {
>>     $_.CounterSamples | ForEach {
>>         [pscustomobject]@{
>>             TimeStamp = $_.TimeStamp
>>             Path = $_.Path
>>             Value = ([Math]::Round($_.CookedValue, 3))
>>         }
>>         Start-Sleep -s 2
>>     }
>> }

*/
-- sys.dm_db_log_stats ( database_id )
--SELECT * FROM sys.dm_db_log_info ( db_id('ksx'));
--SELECT * FROM sys.dm_db_log_stats( db_id('ksx'));

--select top 100 * from ela_bis3
--sp_helpindex ela_bis3

DECLARE @initiallog int;
DECLARE @finallog int;
DECLARE @differenceinlog int;
DECLARE @datasize int;
DECLARE @logtodataratio decimal(19,10);

--Find initial log size:
SELECT @initiallog = cntr_value FROM master..sysperfinfo
WHERE instance_name = 'ksx'
AND counter_name = 'Log File(s) Used Size (KB)'; 

--SELECT cntr_value,* FROM master..sysperfinfo
--WHERE instance_name = 'ksx'
--AND counter_name = 'Log File(s) Used Size (KB)'; 

--Create an Index:
DROP INDEX IF EXISTS I_ID2  
    ON DBO.ELA_BIS3

CREATE UNIQUE CLUSTERED INDEX I_ID2 ON ELA_BIS3 (ID1)
WITH (ONLINE = ON, MAXDOP=4);

--CREATE NONCLUSTERED INDEX INC_ID1  
--    ON DBO.ELA_BIS3 (ID1)  
--    WHERE ID1 <1000 ;  

--Find new log size:
SELECT @finallog = cntr_value FROM master..sysperfinfo
WHERE instance_name = 'KSX' AND counter_name = 'Log File(s) Used Size (KB)'; 

--Find change in log size:
SET @differenceinlog =  @finallog - @initiallog;

--find index size:
DECLARE @dbid smallint, @objid int;
SET @dbid = DB_ID('KSX');
SET @objid = OBJECT_ID('ELA_BIS3');
SELECT  @datasize =SUM(page_count) FROM sys.dm_db_index_physical_stats(@dbid,@objid,null,null,null)
WHERE index_type_desc = 'CLUSTERED INDEX'; --In case of nonclustered index - 'NONCLUSTERED INDEX'

SET @datasize = @datasize * 8; -- #_of_pages*8

--Find Log-to-Data ratio
SET @logtodataratio = CAST(@differenceinlog AS decimal(19,10))/CAST(@datasize AS decimal(19,10));

SELECT 'Initial Log'= @initiallog/1024, 'Final Log'=@finallog/1024, 
    'Difference in Log'=@differenceinlog/1024, 'Data Size'=@datasize/1024, 
    'Log-to-data ratio'=@logtodataratio
	


GO

/*

SELECT TOP 20
    CONVERT (varchar(30), getdate(), 126) AS runtime,
    CONVERT (decimal (28, 1), 
        migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) 
        ) AS estimated_improvement,
    'CREATE INDEX missing_index_' + 
        CONVERT (varchar, mig.index_group_handle) + '_' + 
        CONVERT (varchar, mid.index_handle) + ' ON ' + 
        mid.statement + ' (' + ISNULL (mid.equality_columns, '') + 
        CASE
            WHEN mid.equality_columns IS NOT NULL
            AND mid.inequality_columns IS NOT NULL THEN ','
            ELSE ''
        END + ISNULL (mid.inequality_columns, '') + ')' + 
        ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON 
    migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON 
    mig.index_handle = mid.index_handle
ORDER BY estimated_improvement DESC;
*/

--use ksx

--CREATE UNIQUE NONCLUSTERED INDEX tola
--    ON dbo.ela_bis3
 --   (id)

/*
SELECT TOP 20
	qsq.query_id,
    SUM(qrs.count_executions) * AVG(qrs.avg_logical_io_reads) as est_logical_reads,
    SUM(qrs.count_executions) AS sum_executions,
    AVG(qrs.avg_logical_io_reads) AS avg_avg_logical_io_reads,
    SUM(qsq.count_compiles) AS sum_compiles,
    (SELECT TOP 1 qsqt.query_sql_text FROM sys.query_store_query_text qsqt
        WHERE qsqt.query_text_id = MAX(qsq.query_text_id)) AS query_text,    
    TRY_CONVERT(XML, (SELECT TOP 1 qsp2.query_plan from sys.query_store_plan qsp2
        WHERE qsp2.query_id=qsq.query_id
        ORDER BY qsp2.plan_id DESC)) AS query_plan
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp on qsq.query_id=qsp.query_id
CROSS APPLY (SELECT TRY_CONVERT(XML, qsp.query_plan) AS query_plan_xml) AS qpx
JOIN sys.query_store_runtime_stats qrs on 
    qsp.plan_id = qrs.plan_id
JOIN sys.query_store_runtime_stats_interval qsrsi on 
    qrs.runtime_stats_interval_id=qsrsi.runtime_stats_interval_id
WHERE    
    qsp.query_plan like N'%<MissingIndexes>%'
    and qsrsi.start_time >= DATEADD(HH, -48, SYSDATETIME())
GROUP BY qsq.query_id, qsq.query_hash
ORDER BY est_logical_reads DESC;
GO

SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)) 
AS [Available Space In MB], f.[file_id], fg.name AS [Filegroup Name],
f.is_percent_growth, f.growth, fg.is_default, fg.is_read_only, 
fg.is_autogrow_all_files
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
ORDER BY f.[file_id] OPTION (RECOMPILE);

*/

