USE ksx

ALTER SERVER ROLE [sysadmin] ADD MEMBER [xlogin1]
CREATE LOGIN [xlogin1] WITH PASSWORD=N'tola1234', 
DEFAULT_DATABASE=[ksx], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO


begin
checkpoint
dbcc dropcleanbuffers

select top 100 * from ela

CREATE CLUSTERED INDEX [CU_ela_id1] ON [dbo].[ela]
(
	[ID1],create_date ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = On, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
end
GO 10



PRINT 'ZACZYNAM'


GOTO QuitWithRollback


PRINT 'ZACZYNAM2'

QuitWithRollback:
    PRINT 'YESTEM TU'

EndSave:
   PRINT 'YESTEM TAM'

PRINT 'KONIEC'

---------------------------


sp_who2

0x12DFF9E413833C4C92FB60007BE995F2

sp_who2

--SQLAgent - TSQL JobStep (Job 0x12DFF9E413833C4C92FB60007BE995F2 : Step 1)

-- Good One
SELECT
	job_id, name, 
	N'TSQL JobStep (Job ' + CONVERT(VARCHAR(36), CONVERT(BINARY(16), job_id), 1) + '%'
FROM msdb.dbo.sysjobs

SET SHOWPLAN_ALL ON;
SET SHOWPLAN_TEXT ON

SET SHOWPLAN_XML OFF;

SET STATISTICS XML OFF

USE ksx

SELECT TOP  100 * FROM [dbo].ela
WHERE object_id IN (1,2,3)




SELECT job_id, name,
	CONVERT(BINARY(16),job_id) as x,
	'SQLAgent - TSQL JobStep (Job ',
	 CONVERT(VARCHAR(36), CONVERT(BINARY(16), job_id), 1)
	 CAST(job_id AS VARCHAR(MAX))
--	'SQLAgent - TSQL JobStep (Job '+ CONVERT(BINARY(16),job_id) + '%'
	FROM msdb.dbo.sysjobs
WHERE CONVERT(BINARY(16),job_id) = 0x12DFF9E413833C4C92FB60007BE995F2;

SELECT CAST(myBinaryCol AS VARCHAR(MAX))
FROM myTable

--job_id 	UNIQUEIDENTIFIER

	DECLARE  @app NVARCHAR(256) = APP_NAME(),
	
	IF (@app LIKE N'SQLAgent - TSQL JobStep (Job 0x12DFF9E413833C4C92FB60007BE995F2%'
		or @app LIKE N'SQLAgent - TSQL JobStep (Job 0x12DFF9E413833C4C92FB60007BE995F2%')
	begin

	end


select 
ORIGINAL_DB_NAME()
,app_name()
,SUSER_NAME()
,db_name()
,SYSTEM_USER
,HOST_NAME()
,ORIGINAL_LOGIN()

use master
--DISABLE TRIGGER ALL ON all SERVER
-- ENABLE Trigger ALL ON ALL SERVER;  


IF ORIGINAL_LOGIN()= N'login_test' AND  
    (SELECT COUNT(*) FROM sys.dm_exec_sessions  
            WHERE is_user_process = 1 AND  
                original_login_name = N'login_test') > 3

use msdb

EXEC msdb.dbo.sp_start_job N'tola_job' ;  
GO 




set nocount on

-- create workload
declare @i int =0

WHILE 1=1
BEGIN
SELECT @i = COUNT(*) FROM ela WHERE name LIKE '%C%'
set @i = ( SELECT COUNT(*) AS ILE1 FROM ela WHERE name LIKE '%C%' )
END

/*
WHILE 1=1
BEGIN
  SELECT COUNT(*) AS ILE FROM ela
  SELECT COUNT(*) AS ILE1 FROM ela WHERE name LIKE '%A%'
END
*/

alter database ksx set recovery simple


-- Resource Governor
-- Turn resourse governor ON
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO

ALTER RESOURCE GOVERNOR DISABLE
-- is it enabled
select * from sys.resource_governor_configuration 


alter resource pool rp_origami
with (			cap_cpu_percent=80 )

alter resource pool rp_origami
with ( AFFINITY SCHEDULER = auto )


alter resource pool rp_origami 
with (	max_iops_per_volume=1500)


ALTER RESOURCE GOVERNOR reconfigure


CREATE RESOURCE POOL [RP_origami] WITH
		(
		min_cpu_percent=0, 
		max_cpu_percent=50, 
		cap_cpu_percent=50, 
		AFFINITY SCHEDULER = AUTO, 
		min_iops_per_volume=0, 
		max_iops_per_volume=100
		);

CREATE WORKLOAD GROUP [WG_origami] WITH
(
		group_max_requests=0, 
		importance=High, 
		max_dop=2
)
		USING [RP_origami]

use master

CREATE OR ALTER FUNCTION [dbo].[origami_Classifier]() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname

if suser_sname() = 'xlogin1'
SET @grp_name = 'WG_origami';
else
SET @grp_name = 'Default'  ;
	-- Result
    RETURN @grp_name 
END;

GO





CREATE RESOURCE POOL [l_Proficy] WITH
		(
		min_cpu_percent=25, 
		max_cpu_percent=90, 
		min_memory_percent=10, 
		max_memory_percent=50, 
		cap_cpu_percent=20, 
		AFFINITY SCHEDULER = AUTO, 
		min_iops_per_volume=20, 
		max_iops_per_volume=2147483647
		);

ALTER RESOURCE POOL [l_Proficy] WITH
(
		min_cpu_percent=24, 
		max_cpu_percent=25, 
		min_memory_percent=10, 
		min_iops_per_volume=20, 
		max_iops_per_volume=2147483647,
				cap_cpu_percent=30,
		--AFFINITY SCHEDULER = (0 TO 1, 3) 
		AFFINITY SCHEDULER = (0 TO 1) 
)

GO

ALTER RESOURCE POOL [default] WITH
(
		AFFINITY SCHEDULER = auto
)


CREATE WORKLOAD GROUP [L_WG_PROFICY_1] WITH
(
		group_max_requests=0, 
		importance=High, 
		request_max_cpu_time_sec=0, 
		request_max_memory_grant_percent=25, 
		request_memory_grant_timeout_sec=0, 
		max_dop=4
)
		USING [PoolAdmin],
		EXTERNAL [default]

GO


DROP WORKLOAD GROUP [L_WG_PROFICY]
GO

ALTER WORKLOAD GROUP [L_WG_PROFICY] WITH(group_max_requests=0, 
		importance=High, 
		request_max_cpu_time_sec=0, 
		request_max_memory_grant_percent=95, 
		request_memory_grant_timeout_sec=0, 
		max_dop=4)
GO

-- Change WorkLoad Group to new resourse pool
ALTER WORKLOAD GROUP [L_WG_PROFICY_1] USING [l_Proficy]


SELECT osn.memory_node_id AS [numa_node_id], sc.cpu_id, sc.scheduler_id  
FROM sys.dm_os_nodes AS osn  
INNER JOIN sys.dm_os_schedulers AS sc   
    ON osn.node_id = sc.parent_node_id   
    AND sc.scheduler_id < 1048576;  

select * from sys.dm_resource_governor_resource_pools

-- Always use after any change
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO


--CREATE WORKLOAD GROUP [GroupReports] 
--CREATE WORKLOAD GROUP [GroupAdmin] 
--CREATE WORKLOAD GROUP [GroupDWH] 
--GO	

CREATE or ALTER FUNCTION [dbo].[RG_Classifier]() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname

    IF (SUSER_NAME()  = 'sa')
        SET @grp_name = 'GroupAdmin'





















    IF (SUSER_NAME()  =  'Reports')
        SET @grp_name = 'GroupReports'

    IF (SUSER_NAME() LIKE 'DataW%')
        SET @grp_name = 'GroupDWH'

    RETURN @grp_name 
END;
GO

CREATE OR ALTER FUNCTION [dbo].[RG_Classifier_1]() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname


  IF (APP_NAME() LIKE '%MANAGEMENT STUDIO%')
      SET @grp_name = 'L_WG_PROFICY';
  IF (APP_NAME() LIKE '%REPORT%')
      SET @grp_name = 'L_WG_PROFICY';

  
    RETURN @grp_name 
END;
GO

USE master
GO

CREATE OR ALTER FUNCTION [dbo].[RG_Classifier_1]() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname

if ORIGINAL_DB_NAME() = 'ksx1'
SET @grp_name = 'L_WG_PROFICY';
else
IF (APP_NAME() LIKE '%REPORT%')
      SET @grp_name = 'L_WG_PROFICY';
else
  IF (APP_NAME() LIKE '%MANAGEMENT STUDIO%')
      SET @grp_name = 'L_WG_PROFICY'
	ELSE SET @grp_name = 'Default'  ;
	-- Result
    RETURN @grp_name 
END;
GO

sp_helptext N'[dbo].[RG_Classifier_1]'
SELECT OBJECT_DEFINITION (OBJECT_ID('[dbo].[RG_Classifier_1]')) AS ObjectDefinition 
select ROUTINE_NAME, ROUTINE_DEFINITION, LAST_ALTERED 
from INFORMATION_SCHEMA.ROUTINES where SPECIFIC_NAME = 'RG_Classifier_1'


SELECT ConSess.session_id, ConSess.login_name,  WorLoGroName.name
  FROM sys.dm_exec_sessions AS ConSess
  JOIN sys.dm_resource_governor_workload_groups AS WorLoGroName
      ON ConSess.group_id = WorLoGroName.group_id
 WHERE session_id > 60;

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.origami_Classifier);
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo. RG_Classifier_1);
GO


ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = null);
GO

-- Start Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO	

--A thing to note is that after you create the classifier function and assign it to the Resource Governor, 
--you are not allowed to drop or alter it. Even if you disable Resource Governor, you are not allowed to alter the classifier function 
--once it is assigned.

--To work around this issue, you can create another classifier function and assign it to the Resource Governor and do the changes to the 
--first function and allocate it back to the Resource Governor. Yes, I agree that this should not be the way to do this, but this is a way
--to make a change.

/*
CREATE RESOURCE POOL PoolAdmin
WITH (MAX_CPU_PERCENT = 20);

ALTER RESOURCE POOL PoolAdmin  
WITH (MAX_CPU_PERCENT = 25);  
GO  

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO  
 
ALTER WORKLOAD GROUP GroupAdmin
USING PoolAdmin;	

-- Create a new resource pool and set a maximum CPU limit.
CREATE RESOURCE POOL PoolReports
WITH (MAX_CPU_PERCENT = 80);
 
ALTER WORKLOAD GROUP GroupReports
USING PoolReports;
 
-- Create a new resource pool and set a maximum CPU limit.
CREATE RESOURCE POOL PoolDWH
WITH (MAX_CPU_PERCENT = 30);
 
ALTER WORKLOAD GROUP GroupDWH
USING PoolDWH;		

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
*/

USE master;  
SELECT * FROM sys.resource_governor_resource_pools;  
SELECT * FROM sys.resource_governor_workload_groups;  
GO  

--- Get the classifier function Id and state (enabled).  
SELECT OBJECT_NAME(classifier_function_id), * FROM sys.resource_governor_configuration;  
GO  

--- Get the classifer function name and the name of the schema  
--- that it is bound to.  
SELECT   
      object_schema_name(classifier_function_id) AS [schema_name],  
      object_name(classifier_function_id) AS [function_name]  
FROM sys.dm_resource_governor_configuration;  


SELECT * FROM sys.dm_resource_governor_resource_pools;  
SELECT * FROM sys.dm_resource_governor_workload_groups;  
GO  

SELECT s.group_id, CAST(g.name as nvarchar(20)), s.session_id, s.login_time, 
    CAST(s.host_name as nvarchar(20)), CAST(s.program_name AS nvarchar(20))
	,s.login_name
	,s.*
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_resource_governor_workload_groups AS g  
    ON g.group_id = s.group_id  
	where s.login_name= 'xlogin1'
ORDER BY g.name;  
GO  


SELECT r.group_id, g.name, r.status, r.session_id, r.request_id, 
    r.start_time, r.command, r.sql_handle, t.text   
FROM sys.dm_exec_requests AS r  
INNER JOIN sys.dm_resource_governor_workload_groups AS g  
    ON g.group_id = r.group_id  
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t  
ORDER BY g.name;  
GO  

SELECT s.group_id, g.name, s.session_id, s.login_time, s.host_name, s.program_name   
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_resource_governor_workload_groups AS g  
    ON g.group_id = s.group_id  
       AND 'preconnect' = s.status  
ORDER BY g.name;  
GO  

SELECT r.group_id, g.name, r.status, r.session_id, r.request_id, r.start_time, 
    r.command, r.sql_handle, t.text   
FROM sys.dm_exec_requests AS r  
INNER JOIN sys.dm_resource_governor_workload_groups AS g  
    ON g.group_id = r.group_id  
       AND 'preconnect' = r.status  
 CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t  
ORDER BY g.name;  
GO  

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO
ALTER RESOURCE GOVERNOR DISABLE
GO

/*
DROP FUNCTION dbo.UDFClassifier
GO

DROP WORKLOAD GROUP ReportServerGroup
GO
DROP WORKLOAD GROUP PrimaryServerGroup
GO
DROP RESOURCE POOL ReportServerPool
GO
DROP RESOURCE POOL PrimaryServerPool
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO
*/

USE master;  
go  
-- Get the stored metadata.  
SELECT   
object_schema_name(classifier_function_id) AS 'Classifier UDF schema in metadata',   
object_name(classifier_function_id) AS 'Classifier UDF name in metadata' 
,*
FROM   
sys.resource_governor_configuration;  
go  

-- Get the in-memory configuration.  
SELECT   
object_schema_name(classifier_function_id) AS 'Active classifier UDF schema',   
object_name(classifier_function_id) AS 'Active classifier UDF name'
,*
FROM   
sys.dm_resource_governor_configuration;  
go  


EXEC msdb.dbo.sp_start_job 'tola_job'

https://www.mssqltips.com/sqlservertip/6111/query-sql-server-agent-jobs-job-steps-history-and-schedule-system-tables/

--remember to return default pool

