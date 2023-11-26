
/* 
Krzysztof Szwarc 
Version 1.0, 2021-10-16
Detaching Database 
*/

/*
sp_configure 'Show Advanced Options',1
go
reconfigure
go
sp_configure 'xp_cmdshell',1
go   
reconfigure
go
*/


/*
ALTER LOGIN [xlogin1] DISABLE
GO
ALTER LOGIN [xlogin2] DISABLE
GO
ALTER LOGIN [xlogin1] ENABLE
GO
ALTER LOGIN [xlogin2] ENABLE
GO
*/
-- Enable and disable job
--exec msdb..sp_update_job @job_name = 'TOLA_JOB', @enabled = 0 --Disable
--exec msdb..sp_update_job @job_name = 'TOLA_JOB', @enabled = 1 --Enable

--EXEC xp_servicecontrol N'stop',N'SQLServerAGENT'
--EXEC xp_servicecontrol N'start',N'SQLServerAGENT'

-- lists activity for all jobs that the current user has permission to view.  
USE msdb ;  
GO  
EXEC dbo.sp_help_jobactivity ;  
GO  

EXEC dbo.sp_stop_job  
    N'tola_job' ;  
GO  

EXEC dbo.sp_start_job N'tola_job';  
GO  

--WAITFOR DELAY '00:01';
--WAITFOR DELAY '00:00:10'

SELECT
    job.Name, job.job_ID
    ,job.Originating_Server
    ,activity.run_requested_Date
    ,datediff(minute, activity.run_requested_Date, getdate()) AS Elapsed
FROM
    msdb.dbo.sysjobs_view job 
        INNER JOIN msdb.dbo.sysjobactivity activity
        ON (job.job_id = activity.job_id)
WHERE
    run_Requested_date is not null 
    AND stop_execution_date is null
    AND job.name like 'Your Job Prefix%'


SELECT  j.name AS 'Job Name',
    j.job_id AS 'Job ID',
    j.originating_server AS 'Server',
    a.run_requested_date AS 'Execution Date',
    DATEDIFF(SECOND, a.run_requested_date, GETDATE()) AS 'Elapsed(sec)',
    CASE WHEN a.last_executed_step_id is null
        THEN 'Step 1 executing'
        ELSE 'Step ' + CONVERT(VARCHAR(25), last_executed_step_id + 1)
                  + ' executing'
        END AS 'Progress'
FROM msdb.dbo.sysjobs_view j
    INNER JOIN msdb.dbo.sysjobactivity a ON j.job_id = a.job_id
    INNER JOIN msdb.dbo.syssessions s ON s.session_id = a.session_id
    INNER JOIN (SELECT MAX(agent_start_date) AS max_agent_start_date
          FROM msdb.dbo.syssessions) s2 ON s.agent_start_date = s2.max_agent_start_date
WHERE stop_execution_date IS NULL
AND run_requested_date IS NOT NULL


USE [master]
GO
ALTER DATABASE [ksx] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO




GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'ksx'
GO

USE [master]
GO

CREATE DATABASE [ksx] ON 
( FILENAME = N'C:\SQL\MSSQL15.SQL1\MSSQL\DATA\D1\ksx.mdf' ),
( FILENAME = N'C:\SQL\MSSQL15.SQL1\MSSQL\DATA\L1\ksx_log.ldf' )
 FOR ATTACH
GO

ALTER DATABASE [ksx] SET MULTI_USER
ALTER DATABASE [ksx] SET SINGLE_USER WITH rollback immediate

GO

--ALTER DATABASE [ksx] SET MULTI_USER

-- Showing active connections
SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame

--Showing connected users
SELECT conn.session_id, host_name, program_name, db_name(sess.database_id) as DBName,
    nt_domain, login_name, connect_time, last_request_end_time
	,conn.*,sess.*
FROM sys.dm_exec_sessions AS sess
JOIN sys.dm_exec_connections AS conn
   ON sess.session_id = conn.session_id;



Declare @dbName varchar(150)
set @dbName = 'ksx'

--Total machine connections
--SELECT  COUNT(dbid) as TotalConnections FROM sys.sysprocesses WHERE dbid > 0

--Available connections
DECLARE @SPWHO1 TABLE (DBName VARCHAR(1000) NULL, NoOfAvailableConnections VARCHAR(1000) NULL, LoginName VARCHAR(1000) NULL)
INSERT INTO @SPWHO1 
    SELECT db_name(dbid), count(dbid), loginame FROM sys.sysprocesses WHERE dbid > 0 GROUP BY dbid, loginame
SELECT * FROM @SPWHO1 WHERE DBName = @dbName

--Running connections
DECLARE @SPWHO2 TABLE (SPID VARCHAR(1000), [Status] VARCHAR(1000) NULL, [Login] VARCHAR(1000) NULL, HostName VARCHAR(1000) NULL, BlkBy VARCHAR(1000) NULL, DBName VARCHAR(1000) NULL, Command VARCHAR(1000) NULL, CPUTime VARCHAR(1000) NULL, DiskIO VARCHAR(1000) NULL, LastBatch VARCHAR(1000) NULL, ProgramName VARCHAR(1000) NULL, SPID2 VARCHAR(1000) NULL, Request VARCHAR(1000) NULL)
INSERT INTO @SPWHO2 
    EXEC sp_who2 'Active'
SELECT * FROM @SPWHO2 WHERE DBName = @dbName


--==============================================================================
-- See who is connected to the database.
-- Analyse what each spid is doing, reads and writes.
-- If safe you can copy and paste the killcommand - last column.
-- Marcelo Miorelli
-- 18-july-2017 - London (UK)
-- Tested on SQL Server 2016.
--==============================================================================
USE master
go
SELECT
     sdes.session_id
    ,sdes.login_time
    ,sdes.last_request_start_time
    ,sdes.last_request_end_time
    ,sdes.is_user_process
    ,sdes.host_name
    ,sdes.program_name
    ,sdes.login_name
    ,sdes.status

    ,sdec.num_reads
    ,sdec.num_writes
    ,sdec.last_read
    ,sdec.last_write
    ,sdes.reads
    ,sdes.logical_reads
    ,sdes.writes

    ,sdest.DatabaseName
    ,sdest.ObjName
    ,sdes.client_interface_name
    ,sdes.nt_domain
    ,sdes.nt_user_name
    ,sdec.client_net_address
    ,sdec.local_net_address
    ,sdest.Query
    ,KillCommand  = 'Kill '+ CAST(sdes.session_id  AS VARCHAR)
FROM sys.dm_exec_sessions AS sdes
INNER JOIN sys.dm_exec_connections AS sdec
        ON sdec.session_id = sdes.session_id
CROSS APPLY (
    SELECT DB_NAME(dbid) AS DatabaseName
        ,OBJECT_NAME(objectid) AS ObjName
        ,COALESCE((
            SELECT TEXT AS [processing-instruction(definition)]
            FROM sys.dm_exec_sql_text(sdec.most_recent_sql_handle)
            FOR XML PATH('')
                ,TYPE
            ), '') AS Query
    FROM sys.dm_exec_sql_text(sdec.most_recent_sql_handle)
) sdest
WHERE sdes.session_id <> @@SPID
  AND sdest.DatabaseName ='ksx'
--ORDER BY sdes.last_request_start_time DESC
