
/*
https://am2.co/2019/12/changing-a-column-from-int-to-bigint-without-downtime/
*/
-- Main DataBase

USE ksx

--SP_SPACEUSED 'BIGTABLE';
--go

DBCC SHRINKFILE (N'ksx_log' , 100)



TRUNCATE TABLE BIGTABLE


DROP TABLE IF EXISTS dbo.BigTable;
GO

CREATE TABLE dbo.BigTable (
    ID          int identity(1,1),
    AnotherID   int,
    Filler      nvarchar(1000),
    CONSTRAINT  PK_BigTable PRIMARY KEY CLUSTERED (ID)
    );
GO
INSERT INTO dbo.BigTable (AnotherID, Filler)
SELECT top 20000 o.object_id, REPLICATE('z',1000)
FROM sys.objects o, sys.objects o1, sys.objects o2;

/*
Nice comments
*/

exec XP_FIXEDDRIVES


DROP TABLE IF EXISTS dbo.BigTable;
GO
CREATE TABLE dbo.BigTable (
    ID          int identity(1,1),
    AnotherID   int,
    Filler      nvarchar(1000),
    CONSTRAINT  PK_BigTable PRIMARY KEY CLUSTERED (ID) WITH (DATA_COMPRESSION = ROW) --now with compression
    );
GO
INSERT INTO dbo.BigTable (AnotherID, Filler)
SELECT top 20000 o.object_id, REPLICATE('z', 1000)
FROM sys.objects o, sys.objects o1, sys.objects o2;

-- Instant
ALTER TABLE dbo.BigTable ALTER COLUMN AnotherID bigint WITH(ONLINE=ON);

-- cannot be done due to index PK
ALTER TABLE dbo.BigTable ALTER COLUMN ID bigint WITH(ONLINE=ON);



CREATE TABLE dbo.BigTable_new (
    ID          bigint identity(2147483648,1), --bigint and a big seed 
    AnotherID   int,
    Filler      nvarchar(1000),
    CONSTRAINT PK_BigTable_new PRIMARY KEY CLUSTERED (ID) WITH (DATA_COMPRESSION = ROW)
    );

/*
A delete (this has to be first)
	On insert, there’s nothing in the _new table, so this delete is a no-op
	On delete, this will do the delete from the _new table. 
		If the rows haven’t yet been migrated from old to new, there’s nothing to delete, so this is a no-op
	On update, this will delete the rows from the _new table (and we’ll re-insert them in the next statement).
		If the rows haven’t yet been migrated from old to new,there’s nothing to delete, so this is a no-op


An insert (this has to be second)
	On insert, this will insert the identical row into the _new table
	On delete, there’s nothing to insert to the _new table, so this insert is a no-op
	On update, this will insert the proper row to the _new table (we previously deleted the old version, if it existed). 
	If the rows hadn’t previously been migrated from old to new, we just migrated the rows!

*/

-- Super trigger to keep tables in sync
CREATE OR ALTER TRIGGER dbo.SyncBigTables  
     ON dbo.BigTable  
     AFTER INSERT, UPDATE, DELETE  
AS 
SET NOCOUNT ON;

-- Step 1 
DELETE n
FROM dbo.BigTable_new AS n
JOIN deleted d ON d.ID = n.id; --join on that PK
 
SET IDENTITY_INSERT dbo.BigTable_new ON;

INSERT INTO dbo.BigTable_new (ID, AnotherID, Filler)
SELECT i.ID, i.AnotherID, i.Filler
FROM inserted AS i;

SET IDENTITY_INSERT dbo.BigTable_new OFF;
go

--------------------------------------------------------------------------

SELECT * FROM dbo.BigTable_new;

--Deletes on the old table still work; nothing to delete in new table:

SELECT * FROM dbo.BigTable WHERE ID = 1;
SELECT * FROM dbo.BigTable_new WHERE ID = 1;
 
DELETE dbo.BigTable WHERE ID = 1;
 
SELECT * FROM dbo.BigTable WHERE ID = 1;
SELECT * FROM dbo.BigTable_new WHERE ID = 1;

--Updates will magically migrate rows over to the new table as they change:

SELECT * FROM dbo.BigTable WHERE ID = 2;
SELECT * FROM dbo.BigTable_new WHERE ID = 2;
 
UPDATE dbo.BigTable SET Filler = 'updated' WHERE ID = 2;
 
SELECT * FROM dbo.BigTable WHERE ID = 2;
SELECT * FROM dbo.BigTable_new WHERE ID = 2;


----------------------------------------------------------------
--Inserts on the old table get inserted nicely on the new table:

DECLARE @ID bigint;
INSERT INTO dbo.BigTable (Filler)
VALUES ('Brand New Row');
 
SELECT @ID = SCOPE_IDENTITY();
 
SELECT * FROM dbo.BigTable WHERE ID = @ID;
SELECT * FROM dbo.BigTable_new WHERE ID = @ID;


----------------------------------------------
DROP TABLE IF EXISTS dbo.WhereAmI;
GO

SELECT * FROM dbo.WhereAmI;

CREATE TABLE dbo.WhereAmI (
    TableName   nvarchar(128),
    LastID      bigint,
    MaxID       bigint
    CONSTRAINT PK_WhereAmI PRIMARY KEY CLUSTERED (TableName)
    );

INSERT INTO dbo.WhereAmI (TableName, LastID, MaxID)
SELECT 'BigTable', MIN(ID), MAX(ID) FROM dbo.BigTable;
GO

SELECT * FROM dbo.WhereAmI;


SET NOCOUNT ON;
 

--------------------- Main Data Movement
DECLARE @BatchSize smallint = 100;
DECLARE @LastID bigint;
DECLARE @MaxID bigint;
 
SELECT @LastID = LastID,
       @MaxID  = MaxID
FROM dbo.WhereAmI
WHERE TableName = 'BigTable';

DECLARE @msg1 varchar(3000) 
set @msg1 = 'Stage:'+ str(@lastId) 
 
WHILE @LastID < @MaxID
BEGIN

	set @msg1 = 'Stage:'+ str(@lastId) 
	RAISERROR (@msg1, 0, 1) WITH NOWAIT
	
    SET IDENTITY_INSERT dbo.BigTable_new ON;
    
	INSERT INTO dbo.BigTable_new (ID, AnotherID, Filler)
    SELECT o.ID, o.AnotherID, o.Filler
    FROM dbo.BigTable AS o
    WHERE o.ID >= @LastID
    AND o.ID < @LastID + @BatchSize  --Yeah, we could do a TOP(@BatchSize), too.
    AND NOT EXISTS (SELECT 1 FROM dbo.BigTable_new AS n WHERE n.ID = o.ID);
    
	SET IDENTITY_INSERT dbo.BigTable_new OFF;
     
    SET @LastID =  @LastID + @BatchSize;
    
	UPDATE w
    SET LastID =  @LastID
    FROM dbo.WhereAmI AS w
    WHERE w.TableName = 'BigTable';
 
END;
GO

--------------------


select * from WhereAmI

-- Zerowanie
update x set lastID = 0  from WhereAmI as x

SELECT * FROM dbo.BigTable WHERE ID = 100;
SELECT * FROM dbo.BigTable_new WHERE ID = 100;

SELECT COUNT(*) FROM dbo.BigTable ;
SELECT COUNT(*) FROM dbo.BigTable_new ;

truncate table BigTable_new

SELECT * FROM dbo.BigTable WHERE ID = 2;
SELECT * FROM dbo.BigTable_new WHERE ID = 2;

-- RaiseError instead of print
DECLARE @msg1 varchar(max) = 'SQLAuthority'+ REPLICATE(' ',8000)
DECLARE @msg2 varchar(max) = 'Pinal'+ REPLICATE(' ',116)
DECLARE @msg3 varchar(max) ='Final Message'

RAISERROR (@msg1, 0, 1) WITH NOWAIT
RAISERROR (@msg2, 0, 1) WITH NOWAIT
WAITFOR DELAY '00:00:05'
RAISERROR (@msg3, 0, 1) WITH NOWAIT



-- Znalesc statystyki uruchomien tego polecenia z DMV
-- Znalesc dmv z perf countera

SELECT 
  p.usecounts, 
  execcounts = s.execution_count,
  mintime    = s.min_elapsed_time,
  maxtime    = s.max_elapsed_time,
  lasttime   = s.last_elapsed_time, 
  qp.query_plan
FROM sys.dm_exec_query_stats AS s
INNER JOIN sys.dm_exec_cached_plans AS p
ON s.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan_stats(s.plan_handle) AS qp
WHERE t.[text] LIKE N'%INSERT INTO dbo.BigTable_new (ID, AnotherID, Filler)%'
--  AND t.[text] NOT LIKE '%dm_exec%';


--- Percent completion

SELECT  session_id ,
        node_id ,
        physical_operator_name ,
        SUM(row_count) row_count ,
        SUM(estimate_row_count) AS estimate_row_count ,
        IIF(COUNT(thread_id) = 0, 1, COUNT(thread_id)) [Threads] ,
        CAST(SUM(row_count) * 100. / SUM(estimate_row_count) AS DECIMAL(30, 2)) [% Complete] ,
        CONVERT(TIME, DATEADD(ms, MAX(elapsed_time_ms), 0)) [Operator time] ,
        DB_NAME(database_id) + '.' + OBJECT_SCHEMA_NAME(QP.object_id,
                                                        qp.database_id) + '.'
        + OBJECT_NAME(QP.object_id, qp.database_id) [Object Name]
FROM    sys.dm_exec_query_profiles QP
GROUP BY session_id ,
        node_id ,
        physical_operator_name ,
        qp.database_id ,
        QP.OBJECT_ID ,
        QP.index_id
ORDER BY session_id ,
        node_id
GO

---------------
SELECT  QP.session_id ,
        QP.node_id ,
        QP.physical_operator_name ,
        DB_NAME(database_id) + '.' + OBJECT_SCHEMA_NAME(QP.object_id,
                                                        qp.database_id) + '.'
        + OBJECT_NAME(QP.object_id, qp.database_id) [Object Name] ,
        OT.task_state ,
        MAX(WT.wait_duration_ms) [wait_duration_ms] ,
        WT.wait_type
FROM    sys.dm_exec_query_profiles QP
        INNER JOIN sys.dm_os_tasks OT 
   ON OT.task_address = QP.task_address
        LEFT  JOIN sys.dm_os_waiting_tasks WT 
   ON WT.waiting_task_address = QP.task_address
GROUP BY QP.session_id ,
        QP.node_id ,
        QP.physical_operator_name ,
        OT.task_state ,
        QP.database_id ,
        QP.object_id ,
        WT.wait_type

--------------
USE master
GO

--Create Extended Events Session
CREATE EVENT SESSION [Capture_Query_Plan] ON SERVER
ADD EVENT sqlserver.query_post_execution_showplan(
    WHERE ([database_name]=N'ksx')) 
ADD TARGET package0.ring_buffer
WITH ( MAX_MEMORY = 4096 KB ,
        EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS ,
        MAX_DISPATCH_LATENCY = 30 SECONDS ,
        MAX_EVENT_SIZE = 0 KB ,
        MEMORY_PARTITION_MODE = NONE ,
        TRACK_CAUSALITY = OFF ,
        STARTUP_STATE = OFF )
GO

--Start Extended Events Session
ALTER EVENT SESSION [Capture_Query_Plan] ON SERVER STATE = START
GO

--Stop Extended Events Session
ALTER EVENT SESSION [Capture_Query_Plan] ON SERVER STATE = STOP
GO

--Drop Extended Events Session
DROP  EVENT SESSION [Capture_Query_Plan] ON SERVER
GO

use ksx

select top 2000 * from ela
where type_desc like 'coto%'

set statistics io, time on

select top 50 * from ela
where lock_escalation_desc like 'coto%'

select top 100 * from ela
where lock_escalation_desc like 'coto%'

SET STATISTICS XML ON
SET STATISTICS PROFILE ON

use ksx

dbcc dropcleanbuffers


select ela.max_column_id_used, format(COUNT(*),'n0') as il 
from dbo.ela
group by ela.max_column_id_used
having COUNT(*)>10001



