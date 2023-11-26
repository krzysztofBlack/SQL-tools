
SELECT
DMV.session_id,
DMV.command,
DMV.wait_type,
DMV.status,
DMV.dop,
SXML.plan_handle,
SXML.Query_plan
FROM sys.dm_exec_query_statistics_xml(59) AS SXML --Pass the session id here. Like I mentioned 57
JOIN sys.dm_exec_requests AS DMV
ON SXML.session_id = DMV.session_id


SELECT creation_time
,last_execution_time
,total_physical_reads
,total_logical_reads
,total_logical_writes
, execution_count
, total_worker_time
, total_elapsed_time
, total_elapsed_time / execution_count avg_elapsed_time
,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE qs.statement_end_offset END
- qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_elapsed_time / execution_count DESC;


SELECT DISTINCT TOP 20
est.TEXT AS QUERY ,
Db_name(dbid),
eqs.execution_count AS EXEC_CNT,
eqs.max_elapsed_time AS MAX_ELAPSED_TIME,
ISNULL(eqs.total_elapsed_time / NULLIF(eqs.execution_count,0), 0) AS AVG_ELAPSED_TIME,
eqs.creation_time AS CREATION_TIME,
ISNULL(eqs.execution_count / NULLIF(DATEDIFF(s, eqs.creation_time, GETDATE()),0), 0) AS EXEC_PER_SECOND,
total_physical_reads AS AGG_PHYSICAL_READS
FROM sys.dm_exec_query_stats eqs
CROSS APPLY sys.dm_exec_sql_text( eqs.sql_handle ) est
ORDER BY
eqs.max_elapsed_time DESC


SELECT
  GETDATE() as now,
  DATEDIFF(SECOND, transaction_begin_time, GETDATE()) as tran_elapsed_time_seconds,
  st.session_id,
  txt.text, 
  *
FROM
  sys.dm_tran_active_transactions at
  INNER JOIN sys.dm_tran_session_transactions st ON st.transaction_id = at.transaction_id
  LEFT OUTER JOIN sys.dm_exec_sessions sess ON st.session_id = sess.session_id
  LEFT OUTER JOIN sys.dm_exec_connections conn ON conn.session_id = sess.session_id
    OUTER APPLY sys.dm_exec_sql_text(conn.most_recent_sql_handle)  AS txt
ORDER BY
  tran_elapsed_time_seconds DESC;

