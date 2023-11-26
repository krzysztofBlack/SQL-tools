WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT qsqt.query_sql_text,
rts.plan_id, rts. NumExecutions, rts .MinDuration, rts. MaxDuration, rts. AvgDuration, rts. AvgReads, rts. AvgWrites, qsp. QueryPlan, 
qsp. QueryPlan.value(N' (1/MissingIndex/@Table)[1]',
'NVARCHAR(256)') AS TableName, qsp. QueryPlan.value(N'(//MissingIndex/@Schema)[1]',
'NVARCHAR(256)') AS SchemaName, qsp. QueryPlan.value(N'(//MissingIndexGroup/@Impact)[1]',
'DECIMAL (6,4)') AS ProjectedImpact, ColumnGroup.value('./@Usage',
'NVARCHAR(256)') AS ColumnGroupUsage, ColumnGroupColumn.value('./@Name',
'NVARCHAR(256)') AS ColumnName 
FROM sys.query_store_query AS qsq JOIN sys.query_store_query_text AS qsqt
ON qsqt.query_text_id = qsq.query_text_id JOIN ( SELECT query_id,
CAST (query_plan AS XML) AS QueryPlan,
plan_id FROM sys.query_store_plan) AS asp 
ON asp.query_id = qsq.query_id JOIN ( SELECT qsrs.plan_id,
SUM(qsrs.count_executions) AS NumExecutions, MIN(qsrs.min_duration) AS MinDuration, MAX(qsrs.max_duration) AS MaxDuration,
AVG(qsrs.avg_duration) AS AvgDuration, AVG(qsrs.avg_logical_io_reads) AS AvgReads,
FROM sys.query_store_query AS qsq JOIN sys.query_store_query_text AS qsqt
ON qsqt.query_text_id = qsq.query_text_id JOIN ( SELECT query_id,
CAST (query_plan AS XML) AS QueryPlan,
plan_id FROM sys.query_store_plan) AS 9sp ON asp.query_id = qsq.query_id JOIN ( SELECT qsrs.plan_id,
SUM(qsrs.count_executions) AS NumExecutions, MIN(qsrs.min_duration) AS MinDuration, MAX(asrs.max_duration) AS MaxDuration, AVG(qsrs.avg_duration) AS AvgDuration, AVG(qsrs.avg_logical_io reads) AS AvgReads,
AVG(qsrs.avg_logical_io_writes) AS AvgWrites FROM sys.query_store_runtime_stats AS qsrs
GROUP BY qsrs.plan_id) AS rts ON rts.plan_id = qsp.plan_id CROSS APPLY qsp. QueryPlan.nodes('//MissingIndexes/MissingIndexGroup/MissingIndex/Column Group') AS t1 Column Group) CROSS APPLY t1.Column Group.nodes('./Column') AS t2 ColumnGroupColumn);




WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT asat.query_sql_text,
rts.plan_id, 
rts. NumExecutions, 
rts. MinDuration,
rts. MaxDuration, 
rts. AvgDuration,
rts. AvgReads,
rts. AvgWrites,
osp. QueryPlan
--qep. QueryPlan.value (N' (//MissingIndex/@Table) [1]',
--"NVARCHAR (256)) AS TableName, qsp. QueryPlan.value (N' (//MissingIndex/@Schema) [1]',
--'NVARCHAR (256)') AS SchemaName, qsp. QueryPlan.value (N' (//MissingIndexGroup/@Impact) [1]'
--'DECIMAL (6,4)') AS ProjectedImpact, ColumnGroup.value("./@Usage'
--"NVARCHAR (256)') AS Column GroupUsage, Column GroupColumn.value('./@Name',
--'NVARCHAR (256)') AS ColumnName
FROM sys.query_store_query AS qsq JOIN sys.query_store_query_text AS qet
ON qaqt.query_text_id = qsq.query_text_id 
JOIN ( SELECT query_id, CAST (query_plan AS XML) AS QueryPlan,
plan_id FROM sys.query_store_plan) As asp
ON gp.query_id = 939.query_id 
JOIN ( SELECT cars.plan_id,
SUM(qsrs.count_executions) AS NumExecutions, MIN (3r3.min_duration) AS MinDuration, MAX (q3r3.max_duration) AS MaxDuration, 
AVG (3r3. avg_duration) AS AvgDuration, AVG (qars. avg_logical_io_reads) AS AvgReads,
AVG (qars. avg_logical_io_writes) AS AvgWrites FROM sys.query_store_runtime_stats AS asrs
GROUP BY qsrs.plan_id) AS rts 
ON rts.plan_id = asp.plan_id CROSS APPLY q3p. QueryPlan.nodes('//Missing Indexes/MissingIndexGroup/MissingIndex/Column Group') AS ti (Colur CROSS APPLY 01. Column Group.nodes ('./Column') AS t2 (Column Group Column);
