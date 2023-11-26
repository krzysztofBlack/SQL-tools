-- select * from sys.dm_os_memory_nodes
-- select * from sys.dm_os_schedulers

-- ligth query profiles
DBCC TRACEON (7412, -1);
GO
dbcc tracestatus

SELECT
DMV.session_id,
DMV.command,
DMV.wait_type,
DMV.status,
DMV.dop,
SXML.plan_handle,
SXML.Query_plan
FROM sys.dm_exec_query_statistics_xml(53) AS SXML --Pass the session id here. Like I mentioned 57
JOIN sys.dm_exec_requests AS DMV
ON SXML.session_id = DMV.session_id

dbcc inputbuffer (53)

SELECT request_id   
FROM sys.dm_exec_requests   
WHERE session_id = 64;  

ALTER DATABASE SCOPED CONFIGURATION SET LIGHTWEIGHT_QUERY_PROFILING = ON

USE [master]
GO
-- Enable Delayed Durability for the database
ALTER DATABASE [ksX] SET DELAYED_DURABILITY = FORCED WITH NO_WAIT
GO


ALTER DATABASE [ksX] SET DELAYED_DURABILITY = disabled WITH NO_WAIT
GO

BEGIN
BEGIN TRAN
INSERT INTO DummyTable VALUES( @counter)
SET @counter = @counter + 1
COMMIT WITH (DELAYED_DURABILITY = ON)
END


DBCC SQLPERF("sys.dm_os_wait_stats", CLEAR)


SELECT TOP(20)
      wait_type
    , wait_time = wait_time_ms / 1000.
    , wait_resource = (wait_time_ms - signal_wait_time_ms) / 1000.
    , wait_signal = signal_wait_time_ms / 1000.
    , waiting_tasks_count
    , percentage = 100.0 * wait_time_ms / SUM(wait_time_ms) OVER ()
    , avg_wait = wait_time_ms / 1000. / waiting_tasks_count
    , avg_wait_resource = (wait_time_ms - signal_wait_time_ms) / 1000. / [waiting_tasks_count]
    , avg_wait_signal = signal_wait_time_ms / 1000.0 / waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE [waiting_tasks_count] > 0
    AND max_wait_time_ms > 0
    AND [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
    )
ORDER BY [wait_time_ms] DESC

/*
ALTER DATABASE TT SET DELAYED_DURABILITY = ALLOWED 
GO 
BEGIN TRANSACTION t 
... 
COMMIT TRANSACTION t WITH (DELAYED_DURABILITY = ON) 
*/

use ksx

SELECT OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
       OBJECT_NAME(ips.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       ips.avg_fragmentation_in_percent,
       ips.avg_page_space_used_in_percent,
       ips.page_count,
       ips.alloc_unit_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(), default, default, default, 'DETAILED') AS ips
INNER JOIN sys.indexes AS i 
ON ips.object_id = i.object_id
   AND
   ips.index_id = i.index_id
ORDER BY page_count DESC;

-- LIMITED, SAMPLED, or DETAILED.
DECLARE @db_id SMALLINT;  
DECLARE @object_id INT;  
  
SET @db_id = DB_ID(N'KSX');  
SET @object_id = OBJECT_ID(N'KSX.DBO.ELA');  
  
IF @db_id IS NULL  
BEGIN;  
    PRINT N'Invalid database';  
END;  
ELSE IF @object_id IS NULL  
BEGIN;  
    PRINT N'Invalid object';  
END;  
ELSE  
BEGIN;  
    SELECT * FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'DETAILED');  
END;  
GO  

--avg_page_space_used_in_percent column indicates page fullness