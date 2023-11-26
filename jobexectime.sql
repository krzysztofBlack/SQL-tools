
WITH jobs AS (
SELECT j.name
,CAST(j.job_id AS VARBINARY) as jobid
,js.step_id
,js.step_name
FROM msdb.dbo.sysjobs j
inner join msdb.dbo.sysjobsteps js on j.job_id = js.job_id
),
runningprocesses as (
SELECT req.session_id, start_time, percent_complete, req.status, command, wait_type, wait_resource, estimated_completion_time,
CASE WHEN ((estimated_completion_time/1000)/3600) > 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)/3600)
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)/3600)
END + ':' +
CASE WHEN ((estimated_completion_time/1000)%3600/60) > 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)%3600/60)
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)%3600/60)
END + ':' +
CASE WHEN ((estimated_completion_time/1000)%60) > 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)%60)
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)%60)
END
AS [Time Remaining], host_name, program_name
, CASE
WHEN PROGRAM_NAME LIKE 'SQLAgent – TSQL JobStep%' THEN convert(varbinary(32), substring(PROGRAM_NAME, 30, 34), 1)
ELSE NULL
END as jobid
,CASE
WHEN PROGRAM_NAME LIKE 'SQLAgent – TSQL JobStep%' THEN LEFT(reverse(replace(program_name,')', '') ), CHARINDEX('', reverse(replace(program_name,')', '') ))- 1)
ELSE NULL
END as jobstepid
FROM sys.dm_exec_requests req
inner join sys.dm_exec_sessions s on req.session_id = s.session_id
WHERE req.session_id > 50
)
SELECT r.session_id, r.start_time, r.percent_complete, r.status, r.command, r.wait_type, r.wait_resource, r.estimated_completion_time, r.[Time Remaining], r.host_name
, r.program_name, j.name AS 'job name'
, r.jobstepid
, j.step_name
FROM runningprocesses r
left outer join jobs j on r.jobid = j.jobid and r.jobstepid = j.step_id;


DBCC FREESYSTEMCACHE('ALL');