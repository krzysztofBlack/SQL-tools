SELECT qt.query_text_id, q.query_id, qt.query_sql_text, qt.statement_sql_handle,  
q.context_settings_id, qs.statement_context_id   
FROM sys.query_store_query_text AS qt  
JOIN sys.query_store_query AS q   
    ON qt.query_text_id = q.query_id  
CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt (qt.query_sql_text, null) AS fn_handle_from_stmt  
JOIN sys.dm_exec_query_stats AS qs   
    ON fn_handle_from_stmt.statement_sql_handle = qs.statement_sql_handle;

select * from sys.dm_os_wait_stats
order by waiting_tasks_count



-- Erin Stellato - finding TempDB page contention old way
select
session_id,
wait_type, 
wait_duration_ms,
blocking_session_id,
resource_description,
ResourceType = CASE 
WHEN PageID = 1 OR PageID % 8088  =  0 THEN 'IS PFS Page!'
WHEN PageID = 2 OR PageID % 511232 = 0 THEN 'IS GAM Page'
WHEN PageID = 3 OR (PageID - 1) % 511232 = 0 THEN 'IS SGAM Page'
ELSE 'Is Not PFS, GAM, or SGAM page'
END
FROM
 ( SELECT
session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
CAST (RIGHT(resource_description, LEN(resource_description)
-CHARINDEX(':', resource_description, 3)) AS INT) AS PageID
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE 'PAGE LATCH_%'
AND resource_description LIKE '2:%' 
) AS tab;



-- SQL Server 2019 Book queries

-- better than Sp_who2
--this query will return a plethora of information in addition to just the session that is blocked
	SELECT r.session_id, r.blocking_session_id, s.*,r.*
	FROM sys.dm_exec_sessions s
	LEFT OUTER JOIN sys.dm_exec_requests r ON r.session_id = s.session_id
	--note: requests represent actions that are executing, sessions are connections, hence LEFT OUTER JOIN
	where is_user_process = 1;



SELECT es.session_id
,es.program_name
,es.login_name
,es.nt_user_name
,es.login_time
,es.host_name
,es.status
,DB_NAME(es.database_id) AS [DB]
,es.cpu_time
,es.total_scheduled_time
,es.total_elapsed_time
,es.memory_usage
,es.logical_reads
,es.reads
,es.writes
,st.text
,ec.local_tcp_port
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_connections ec
ON es.session_id = ec.session_id
LEFT JOIN sys.dm_exec_requests er
ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) st
WHERE es.session_id > 50    -- < 50 system sessions
--AND [login_name] LIKE ”
ORDER BY session_id DESC


--You can see details of what objects are locked by using the sys.dm_tran_locks DMO, or what locks are involved in blocking using this query:

SELECT
t1.resource_type,
t1.resource_database_id,
t1.resource_associated_entity_id,
t1.request_mode,
t1.request_session_id,
t2.blocking_session_id
FROM sys.dm_tran_locks as t1
INNER JOIN sys.dm_os_waiting_tasks as t2
ON t1.lock_owner_address =
t2.resource_address;


use [master];
GO

alter database [ksx] set single_user with rollback immediate
alter database [ksx] set restricted_user with rollback immediate
alter database [ksx] set multi_user with rollback immediate

ALTER DATABASE [ksx] SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO

SET SHOWPLAN_XML ON;

select name, user_access_desc,* from sys.databases

--Dot Net .Net have default isolation level SERIALIZABLE !!!!!!!!!!!!!!!!!!!!!!!!!

SELECT COUNT(*)AS cached_pages_count  
    ,CASE database_id   
        WHEN 32767 THEN 'ResourceDb'   
        ELSE db_name(database_id)   
        END AS database_name  
FROM sys.dm_os_buffer_descriptors  
GROUP BY DB_NAME(database_id) ,database_id  
ORDER BY cached_pages_count DESC;  



SELECT COUNT(*)AS cached_pages_count   
    ,name ,index_id   
FROM sys.dm_os_buffer_descriptors AS bd   
    INNER JOIN   
    (  
        SELECT object_name(object_id) AS name   
            ,index_id ,allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.hobt_id   
                    AND (au.type = 1 OR au.type = 3)  
        UNION ALL  
        SELECT object_name(object_id) AS name     
            ,index_id, allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.partition_id   
                    AND au.type = 2  
    ) AS obj   
        ON bd.allocation_unit_id = obj.allocation_unit_id  
WHERE database_id = DB_ID()  
GROUP BY name, index_id   
ORDER BY cached_pages_count DESC;  

SELECT TOP 10 *  
FROM sys.dm_db_missing_index_group_stats  
ORDER BY avg_total_user_cost * avg_user_impact * (user_seeks + user_scans)DESC;

SELECT migs.group_handle, mid.*  
FROM sys.dm_db_missing_index_group_stats AS migs  
INNER JOIN sys.dm_db_missing_index_groups AS mig  
    ON (migs.group_handle = mig.index_group_handle)  
INNER JOIN sys.dm_db_missing_index_details AS mid  
    ON (mig.index_handle = mid.index_handle)  
WHERE migs.group_handle = 24;  



SELECT
p.usecounts AS UseCount,
p.size_in_bytes / 1024 AS PlanSize_KB,
qs.total_worker_time/1000 AS CPU_ms,
qs.total_elapsed_time/1000 AS Duration_ms,
p.cacheobjtype + ' (' + p.objtype + ')' as
ObjectType,
db_name(convert(int, txt.dbid )) as
DatabaseName,
txt.ObjectID,
qs.total_physical_reads,
qs.total_logical_writes,
qs.total_logical_reads,
qs.last_execution_time,
qs.statement_start_offset as
StatementStartInObject,
SUBSTRING (txt.[text],
qs.statement_start_offset/2 + 1 ,
CASE WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT(nvarchar(max),txt.[text]))
ELSE qs.statement_end_offset/2 - qs.statement_start_offset/2 + 1 END) AS StatementText,
qp.query_plan as QueryPlan,
aqp.query_plan as ActualQueryPlan
FROM sys.dm_exec_query_stats AS qs
INNER JOIN sys.dm_exec_cached_plans p ON
p.plan_handle = qs.plan_handle
OUTER APPLY sys.dm_exec_sql_text (p.plan_handle)
AS txt
OUTER APPLY sys.dm_exec_query_plan
(p.plan_handle) AS qp
OUTER APPLY sys.dm_exec_query_plan_stats
(p.plan_handle) AS aqp --tqp is used for filtering on the text version of the query plan
CROSS APPLY
sys.dm_exec_text_query_plan(p.plan_handle,
qs.statement_start_offset,
qs.statement_end_offset) AS tqp
WHERE txt.dbid = db_id()
ORDER BY qs.total_worker_time +
qs.total_elapsed_time DESC;

--OPTION(USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'));

SELECT * FROM sys.plan_guides;
SELECT *
FROM sys.query_store_query AS qsq
JOIN sys.query_store_plan AS qsp
ON qsp.query_id = qsq.query_id
WHERE qsp.is_forced_plan = 1;


ALTER DATABASE WideWorldImporters SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON );

select * from sys.dm_db_tuning_recommendations

use ksx

-- Missing index
SELECT mid.[statement], create_index_statement = CONCAT('CREATE NONCLUSTERED INDEX IDX_NC_', TRANSLATE(replace(mid.equality_columns, ' '
,''), '],[' ,'___')
, TRANSLATE(replace(mid.inequality_columns, '
' ,''), '],[' ,'___')
, ' ON ‘' , mid.[statement] , ' (' ,
mid.equality_columns
, CASE WHEN mid.equality_columns IS NOT NULL
AND mid.inequality_columns IS NOT NULL THEN
',' ELSE '' END
, mid.inequality_columns , ')'
, ' INCLUDE (' , mid.included_columns , ')' )
, migs.unique_compiles, migs.user_seeks,
migs.user_scans
, migs.last_user_seek, migs.avg_total_user_cost
, migs.avg_user_impact, mid.equality_columns
, mid.inequality_columns, mid.included_columns
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats
migs
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid
ON mig.index_handle = mid.index_handle
INNER JOIN sys.tables t ON t.object_id =
mid.object_id
INNER JOIN sys.schemas s ON s.schema_id =
t.schema_id
WHERE mid.database_id = DB_ID()
-- count of query compilations that needed this proposed index
--AND migs.unique_compiles > 10
-- count of query seeks that needed this proposed index
--AND migs.user_seeks > 10
-- average percentage of cost that could be alleviated with this proposed index
--AND migs.avg_user_impact > 75
-- Sort by indexes that will have the most impact to the costliest queries
ORDER BY migs.avg_user_impact *
migs.avg_total_user_cost desc;



SELECT TableName = sc.name + '.' + o.name,
IndexName = i.name
, s.user_seeks, s.user_scans, s.user_lookups
, s.user_updates
, ps.row_count, SizeMb =
(ps.in_row_reserved_page_count*8.)/1024.
, s.last_user_lookup, s.last_user_scan,
s.last_user_seek
, s.last_user_update
FROM sys.dm_db_index_usage_stats AS s
INNER JOIN sys.indexes AS i
ON i.object_id = s.object_id AND i.index_id = s.index_id
INNER JOIN sys.objects AS o ON o.object_id=i.object_id
INNER JOIN sys.schemas AS sc ON sc.schema_id =o.schema_id
INNER JOIN sys.partitions AS pr ON pr.object_id = i.object_id AND pr.index_id = i.index_id
INNER JOIN sys.dm_db_partition_stats AS ps
ON ps.object_id = i.object_id AND ps.partition_id = pr.partition_id
WHERE o.is_ms_shipped = 0
--Don’t consider dropping any constraints
AND i.is_unique = 0 AND i.is_primary_key = 0 AND
i.is_unique_constraint = 0
--Order by table reads asc, table writes desc
ORDER BY user_seeks + user_scans + user_lookups
asc, s.user_updates desc;


-- Amazing sp_whoIsActive ! from microsoft
    EXEC sp_WhoIsActive
        @get_plans = 1

-- ktora versje wybrac?
ALTER DATABASE SCOPED CONFIGURATION SET DISABLE_INTERLEAVED_EXECUTION_TVF = ON; 

SELECT plan_handle, st.text  
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st  
WHERE text LIKE N'SELECT * FROM Person.Address%';  
GO  

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE



https://sqlserverperformance.wordpress.com/2010/04/20/a-dmv-a-day-%e2%80%93-day-21/

-- Get CPU Utilization History for last 30 minutes (in one minute intervals)
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

SELECT TOP(30) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
      SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
            AS [SystemIdle], 
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
            'int') 
            AS [SQLProcessUtilization], [timestamp] 
      FROM ( 
            SELECT [timestamp], CONVERT(xml, record) AS [record] 
            FROM sys.dm_os_ring_buffers 
            WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
            AND record LIKE '%<SystemHealth>%') AS x 
      ) AS y 
ORDER BY record_id DESC;


--ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp6', FILENAME = N'C:\SQL\MSSQL15.SQL1\MSSQL\DATA\temp_6.ndf' , SIZE = 60MB , FILEGROWTH = 50MB )
--ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp6', SIZE = 70MB )

--USE [tempdb]
--GO
--DBCC SHRINKFILE (N'temp5' , 20)
--DBCC SHRINKFILE (N'temp5',EMPTYFILE )
--ALTER DATABASE [tempdb]  REMOVE FILE [temp6]
--ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp5', SIZE = 20MB )

SELECT SizeinMB = size/128, * FROM sys.sysfiles


SELECT AVG(runnable_tasks_count)
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';


SELECT servicename,
instant_file_initialization_enabled
FROM sys.dm_server_services
WHERE filename LIKE '%sqlservr.exe%';

DBCC MEMORYSTATUS

SELECT sql_memory_model_desc,*
FROM sys.dm_os_sys_info;

--CONVENTIONAL = Lock pages in memory privilege is not granted
--LOCK_PAGES = Lock pages in memory privilege is granted
--LARGE_PAGES = Lock pages in memory privilege is granted in Enterprise mode
-- with Trace Flag 834 ON

--sys.dm_io_virtual_file_stats

-- ALTER DATABASE [ksx] SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT

-----------------------------------


use ksx

begin transaction

update test_history_FK 
set col2_test = 'al'
where col1 = 1

select top 100 * from test_history

select top 100 * from test_history
where id1 = 8

select top 100 * from test_history
where id = 48

    EXEC sp_WhoIsActive
        @get_plans = 1



WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Database)[1]', 'NVARCHAR(256)') AS DatabaseName
,s.sql_handle
,s.total_elapsed_time
,s.last_execution_time
,s.execution_count
,s.total_logical_writes
,s.total_logical_reads
,s.min_elapsed_time
,s.max_elapsed_time
,p.query_plan
,p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Table)[1]', 'NVARCHAR(256)') AS TableName
,p.query_plan.value(N'(/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Schema)[1]', 'NVARCHAR(256)') AS SchemaName
,p.query_plan.value(N'(/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/@Impact)[1]', 'DECIMAL(6,4)') AS ProjectedImpact
,ColumnGroup.value('./@Usage', 'NVARCHAR(256)') AS ColumnGroupUsage
,ColumnGroupColumn.value('./@Name', 'NVARCHAR(256)') AS ColumnName
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) AS p
CROSS APPLY p.query_plan.nodes('/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/sp:ColumnGroup') AS t1 (ColumnGroup)
CROSS APPLY t1.ColumnGroup.nodes('./sp:Column') AS t2 (ColumnGroupColumn)
WHERE p.query_plan.exist(N'/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan//sp:MissingIndexes') = 1
ORDER BY s.total_elapsed_time DESC





/*============================================================================
  File:     WaitingTasks.sql Summary:  Snapshot of waiting tasks
   SQL Server Versions: 2005 onward
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
   (c) 2019, SQLskills.com. All rights reserved. For more scripts and sample code, check out    http://www.SQLskills.com
   You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
   
============================================================================*/
SELECT
    [owt].[session_id] AS [SPID],
    [owt].[exec_context_id] AS [Thread],
    [ot].[scheduler_id] AS [Scheduler],
    [owt].[wait_duration_ms] AS [wait_ms],
    [owt].[wait_type],
    [owt].[blocking_session_id] AS [Blocking SPID],
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            SUBSTRING ( -- earlier versions don't have anything after the nodeID...
                [owt].[resource_description],
                CHARINDEX (N'nodeId=', [owt].[resource_description]) + 7,
                CHARINDEX (N' tid=', [owt].[resource_description] + ' tid=') -
                    CHARINDEX (N'nodeId=', [owt].[resource_description]) - 7
            )
        ELSE NULL
    END AS [Node ID],
    [eqmg].[dop] AS [DOP],
    [er].[database_id] AS [DBID],
    CAST ('https://www.sqlskills.com/help/waits/' + [owt].[wait_type] as XML) AS [Help/Info URL],
    [eqp].[query_plan],
    [est].text
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_os_tasks [ot] ON
    [owt].[waiting_task_address] = [ot].[task_address]
INNER JOIN sys.dm_exec_sessions [es] ON
    [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
    [es].[session_id] = [er].[session_id]
FULL JOIN sys.dm_exec_query_memory_grants [eqmg] ON
    [owt].[session_id] = [eqmg].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE
    [es].[is_user_process] = 1
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO



-------------------------------------
--https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/ 
--------------------------------------
-- Last updated October 1, 2021
WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        -- These wait types are almost 100% never a problem and so they are
        -- filtered out to avoid them skewing the results. Click on the URL
        -- for more information.
        N'BROKER_EVENTHANDLER', -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
        N'BROKER_RECEIVE_WAITFOR', -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
        N'BROKER_TASK_STOP', -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
        N'BROKER_TO_FLUSH', -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
        N'BROKER_TRANSMITTER', -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
        N'CHECKPOINT_QUEUE', -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
        N'CHKPT', -- https://www.sqlskills.com/help/waits/CHKPT
        N'CLR_AUTO_EVENT', -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
        N'CLR_MANUAL_EVENT', -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
        N'CLR_SEMAPHORE', -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE
 
        -- Maybe comment this out if you have parallelism issues
        N'CXCONSUMER', -- https://www.sqlskills.com/help/waits/CXCONSUMER
 
        -- Maybe comment these four out if you have mirroring issues
        N'DBMIRROR_DBM_EVENT', -- https://www.sqlskills.com/help/waits/DBMIRROR_DBM_EVENT
        N'DBMIRROR_EVENTS_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_EVENTS_QUEUE
        N'DBMIRROR_WORKER_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_WORKER_QUEUE
        N'DBMIRRORING_CMD', -- https://www.sqlskills.com/help/waits/DBMIRRORING_CMD
        N'DIRTY_PAGE_POLL', -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
        N'DISPATCHER_QUEUE_SEMAPHORE', -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
        N'EXECSYNC', -- https://www.sqlskills.com/help/waits/EXECSYNC
        N'FSAGENT', -- https://www.sqlskills.com/help/waits/FSAGENT
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
        N'FT_IFTSHC_MUTEX', -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX
  
       -- Maybe comment these six out if you have AG issues
        N'HADR_CLUSAPI_CALL', -- https://www.sqlskills.com/help/waits/HADR_CLUSAPI_CALL
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
        N'HADR_LOGCAPTURE_WAIT', -- https://www.sqlskills.com/help/waits/HADR_LOGCAPTURE_WAIT
        N'HADR_NOTIFICATION_DEQUEUE', -- https://www.sqlskills.com/help/waits/HADR_NOTIFICATION_DEQUEUE
        N'HADR_TIMER_TASK', -- https://www.sqlskills.com/help/waits/HADR_TIMER_TASK
        N'HADR_WORK_QUEUE', -- https://www.sqlskills.com/help/waits/HADR_WORK_QUEUE
 
        N'KSOURCE_WAKEUP', -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
        N'LAZYWRITER_SLEEP', -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
        N'LOGMGR_QUEUE', -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
        N'MEMORY_ALLOCATION_EXT', -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
        N'ONDEMAND_TASK_QUEUE', -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
        N'PARALLEL_REDO_DRAIN_WORKER', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
        N'PARALLEL_REDO_LOG_CACHE', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
        N'PARALLEL_REDO_TRAN_LIST', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
        N'PARALLEL_REDO_WORKER_SYNC', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
        N'PARALLEL_REDO_WORKER_WAIT_WORK', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
        N'PREEMPTIVE_OS_FLUSHFILEBUFFERS', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_OS_FLUSHFILEBUFFERS
        N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
        N'PVS_PREALLOCATE', -- https://www.sqlskills.com/help/waits/PVS_PREALLOCATE
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK', -- https://www.sqlskills.com/help/waits/PWAIT_EXTENSIBILITY_CLEANUP_TASK
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
        N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
        N'QDS_SHUTDOWN_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
        N'REDO_THREAD_PENDING_WORK', -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
        N'REQUEST_FOR_DEADLOCK_SEARCH', -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
        N'RESOURCE_QUEUE', -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
        N'SERVER_IDLE_CHECK', -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
        N'SLEEP_BPOOL_FLUSH', -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
        N'SLEEP_DBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
        N'SLEEP_DCOMSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
        N'SLEEP_MASTERDBREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
        N'SLEEP_MASTERMDREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
        N'SLEEP_MASTERUPGRADED', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
        N'SLEEP_MSDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
        N'SLEEP_SYSTEMTASK', -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
        N'SLEEP_TASK', -- https://www.sqlskills.com/help/waits/SLEEP_TASK
        N'SLEEP_TEMPDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
        N'SNI_HTTP_ACCEPT', -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
        N'SOS_WORK_DISPATCHER', -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
        N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
        N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
        N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
        N'VDI_CLIENT_OTHER', -- https://www.sqlskills.com/help/waits/VDI_CLIENT_OTHER
        N'WAIT_FOR_RESULTS', -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
        N'WAITFOR', -- https://www.sqlskills.com/help/waits/WAITFOR
        N'WAITFOR_TASKSHUTDOWN', -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
        N'WAIT_XTP_RECOVERY', -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
        N'WAIT_XTP_HOST_WAIT', -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
        N'WAIT_XTP_CKPT_CLOSE', -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
        N'XE_DISPATCHER_JOIN', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
        N'XE_DISPATCHER_WAIT', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
        N'XE_TIMER_EVENT' -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
        )
    AND [waiting_tasks_count] > 0
    )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S],
    CAST ('https://www.sqlskills.com/help/waits/' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX( [W1].[Percentage] ) < 99; -- percentage threshold
GO
