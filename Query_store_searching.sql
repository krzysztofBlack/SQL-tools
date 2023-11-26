/*
query store best

https://www.sqlshack.com/the-sql-server-query-store-in-action/
--(local)\SQL1


*/


--SELECT
--	*
--FROM sys.query_store_query
--LEFT JOIN sys.query_store_query_text
--ON query_store_query.query_text_id = query_store_query_text.query_text_id
--LEFT JOIN sys.query_store_plan
--ON query_store_query.query_id = query_store_plan.query_id
--LEFT JOIN sys.query_store_runtime_stats
--ON query_store_plan.plan_id = query_store_runtime_stats.plan_id
--LEFT JOIN sys.query_store_runtime_stats_interval
--ON query_store_runtime_stats.runtime_stats_interval_id = query_store_runtime_stats_interval.runtime_stats_interval_id

use ksx

SELECT * FROM sys.database_query_store_options



SELECT TOP 150
	query_store_query_text.query_sql_text,
	CAST(query_store_plan.query_plan AS XML) AS query_plan_xml,
	query_store_runtime_stats.first_execution_time,
	query_store_runtime_stats.last_execution_time,
	query_store_runtime_stats.count_executions,
	query_store_runtime_stats.avg_duration AS avg_duration_microseconds,
	query_store_runtime_stats.last_duration AS last_duration_microseconds,
	query_store_runtime_stats.avg_cpu_time AS avg_cpu_time_microseconds,
	query_store_runtime_stats.last_cpu_time AS last_cpu_time_microseconds,
	query_store_runtime_stats.avg_logical_io_reads,
	query_store_runtime_stats.last_logical_io_reads,
	query_store_runtime_stats.avg_query_max_used_memory AS avg_query_max_used_memory_8k_pages,
	query_store_runtime_stats.last_query_max_used_memory AS last_query_max_used_memory_8k_pages,
	query_store_runtime_stats.avg_rowcount,
	query_store_runtime_stats.last_rowcount,
	query_store_runtime_stats_interval.start_time AS interval_start_time,
	query_store_runtime_stats_interval.end_time AS interval_end_time,
	query_store_query.query_id,
	query_store_query_text.query_text_id,
	query_store_plan.plan_id
FROM sys.query_store_query
LEFT JOIN sys.query_store_query_text
ON query_store_query.query_text_id = query_store_query_text.query_text_id
LEFT JOIN sys.query_store_plan
ON query_store_query.query_id = query_store_plan.query_id
LEFT JOIN sys.query_store_runtime_stats
ON query_store_plan.plan_id = query_store_runtime_stats.plan_id
LEFT JOIN sys.query_store_runtime_stats_interval
ON query_store_runtime_stats.runtime_stats_interval_id = query_store_runtime_stats_interval.runtime_stats_interval_id
WHERE query_store_runtime_stats_interval.start_time BETWEEN '11/17/2015 22:00:00' AND '11/17/2023 23:00:00'
ORDER BY query_store_runtime_stats.avg_cpu_time DESC
-- ORDER BY query_store_runtime_stats.avg_duration DESC
-- ORDER BY query_store_runtime_stats.count_executions DESC
-- ORDER BY query_store_runtime_stats.avg_logical_io_reads DESC
-- ORDER BY query_store_runtime_stats.avg_rowcount DESC
 

 SELECT TOP 50
	query_store_query.query_id,
	query_store_query_text.query_sql_text,
	CAST(query_store_plan.query_plan AS XML) AS query_plan_xml,
	query_store_runtime_stats.first_execution_time,
	query_store_runtime_stats.last_execution_time,
	query_store_runtime_stats.count_executions,
	query_store_runtime_stats.avg_duration AS avg_duration_microseconds,
	query_store_runtime_stats.last_duration AS last_duration_microseconds,
	query_store_runtime_stats.avg_cpu_time AS avg_cpu_time_microseconds,
	query_store_runtime_stats.last_cpu_time AS last_cpu_time_microseconds,
	query_store_runtime_stats.avg_logical_io_reads,
	query_store_runtime_stats.last_logical_io_reads,
	query_store_runtime_stats.avg_query_max_used_memory AS avg_query_max_used_memory_8k_pages,
	query_store_runtime_stats.last_query_max_used_memory AS last_query_max_used_memory_8k_pages,
	query_store_runtime_stats.avg_rowcount,
	query_store_runtime_stats.last_rowcount
FROM sys.query_store_query
LEFT JOIN sys.query_store_query_text
ON query_store_query.query_text_id = query_store_query_text.query_text_id
LEFT JOIN sys.query_store_plan
ON query_store_query.query_id = query_store_plan.query_id
LEFT JOIN sys.query_store_runtime_stats
ON query_store_plan.plan_id = query_store_runtime_stats.plan_id
LEFT JOIN sys.query_store_runtime_stats_interval
ON query_store_runtime_stats.runtime_stats_interval_id = query_store_runtime_stats_interval.runtime_stats_interval_id
WHERE query_store_runtime_stats_interval.start_time BETWEEN '11/17/2015 22:00:00' AND '11/18/2023 22:00:00'
AND query_store_query_text.query_sql_text LIKE '%Drop index if%'
ORDER BY query_store_runtime_stats.last_execution_time DESC
