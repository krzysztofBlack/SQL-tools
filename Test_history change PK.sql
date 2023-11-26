use ksx

SET SHOWPLAN_ALL ON;
SET SHOWPLAN_TEXT ON
SET SHOWPLAN_XML OFF;
SET STATISTICS XML OFF
USE ksx

SELECT TOP  100 * FROM [dbo].ela
WHERE object_id IN (1,2,3)

SELECT 
	resource_type
	,request_session_id
	,request_Type
	,request_status
	,request_mode
	,resource_description
	,*
FROM sys.dm_tran_locks
WHERE resource_database_id=DB_ID('ksx')

sp_helpindex test_history
sp_spaceused test_history

-- No index
test_history	3100000             	166552 KB	166464 KB	16 KB	72 KB

-- With PK Clustered col1
name			rows					reserved	data		index_size	unused
test_history	3100000             	166936 KB	166464 KB	376 KB	96 KB

-- with clustered index col1,id2
test_history	3100000             	167320 KB	166464 KB	728 KB	128 KB

-- with few indexes
test_history	3100000             	253112 KB	166.464 KB	86.440 KB	208 KB

-- Wnioski: Data size is not changing with or without clustered index 
-- Fragmentation affects size, index size is changing with CI be
--ok
alter table test_history add constraint PK_primary_1 primary key nonclustered (col1) with (maxdop=1, online=off,sort_in_tempdb=off) 
ALTER TABLE [dbo].[test_history] DROP CONSTRAINT [PK_primary_1]

use ksx

alter table test_history add constraint UC_primary_1 unique nonclustered (col1) with (maxdop=1, online=off,sort_in_tempdb=off) 

alter table test_history add constraint PK_primary_1 primary key clustered (col1) with (maxdop=4, online=on,RESUMABLE=ON, sort_in_tempdb=OFF,FILLFACTOR=100) 

CREATE UNIQUE CLUSTERED INDEX [cu_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=1,fillfactor=100)

CREATE UNIQUE NONCLUSTERED INDEX [ncu_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=1,fillfactor=100)

CREATE UNIQUE NONCLUSTERED INDEX [ncu_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=1,fillfactor=100)

CREATE UNIQUE CLUSTERED INDEX [cu_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = On, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=4,fillfactor=100,RESUMABLE=ON)

SELECT total_execution_time, percent_complete, name,state_desc,last_pause_time,page_count
FROM sys.index_resumable_operations;


sp_helpindex test_history
sp_help test_history
select top 100 * from test_history

-- aaaaaaaaaaaaaaaaaa
CREATE UNIQUE NONCLUSTERED INDEX [PK_primary_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = Off, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=2,fillfactor=90)

CREATE UNIQUE CLUSTERED INDEX [PK_primary_1] ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = Off, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = Off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=2,fillfactor=90)


CREATE UNIQUE CLUSTERED INDEX [cu_1] ON [dbo].[test_history] (Col1,id)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = Off, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=2,fillfactor=90)

ALTER TABLE [dbo].[test_history] DROP CONSTRAINT [PK_primary_1]
drop index cu_1 on test_history

EXEC sp_rename N'dbo.test_history.pk_primary_1', N'pk_primary_1_renamed', N'INDEX';   
GO  

CREATE UNIQUE CLUSTERED INDEX pk_primary_1_renamed ON [dbo].[test_history] (Col1)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = Off, RESUMABLE=ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = On, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF,maxdop=2,fillfactor=90,DATA_COMPRESSION=PAGE)

DROP INDEX pk_primary_1_renamed ON DBO.TEST_HISTORY WITH (ONLINE=ON, MAXDOP=2)
ALTER TABLE TEST_HISTORY DROP CONSTRAINT pk_primary_1_renamed  WITH (ONLINE=ON, MAXDOP=2)

EXEC sys.sp_estimate_data_compression_savings
     'DBO', 'TEST_HISTORY', NULL, NULL, 'PAGE'

-- Renaming
EXEC sp_rename N'dbo.test_history.ncu_1', N'ncu_1_renamed1', N'INDEX';   
GO  

EXEC sp_rename N'dbo.test_history.pk_primary_1', N'pk_primary_1_renamed', N'INDEX';   
GO  

EXEC sp_rename N'dbo.test_history.pk_primary_1_renamed', N'pk_primary_1_renamed_2', N'INDEX';   
GO  

ALTER TABLE [dbo].[test_history] DROP CONSTRAINT [pk_primary_1_renamed_2]


--solution create new cluster mix index primary key - foreign key and next rename?
--
-- primary keys can be disabled but then it must be rebuild 
-- ALTER INDEX PK_Employees ON HumanResources.Employees DISABLE;
-- ALTER INDEX <index_name> ON <schema_name>.<table_name> REBUILD;


drop index test_history.cu_1

update test_history set id2 = '123456789Z'
update test_history set col2_test = 'abcde'


select * into test_history from t1a

--alter table test_history alter column col1 bigint not null with (online=off) 

SELECT
	DISABLE_STATEMENT =
		N'ALTER INDEX '
		+ QUOTENAME(si.[name], N']')
		+ N' ON '
		+ QUOTENAME(sch.[name], N']')
		+ N'.' 
		+ QUOTENAME(OBJECT_NAME(so.[object_id]), N']') 
		+ N' DISABLE' 
 	, ENABLE_STATEMENT = 
	 	N'ALTER INDEX ' 
		+ QUOTENAME(si.[name], N']') 
		+ N' ON ' 
		+ QUOTENAME(sch.[name], N']') 
		+ N'.' 
		+ QUOTENAME(OBJECT_NAME(so.[object_id]), N']') 
		+ N' REBUILD' 
FROM sys.indexes AS si
	JOIN sys.objects AS so
		ON si.[object_id] = so.[object_id]
	JOIN sys.schemas AS sch
		ON so.[schema_id] = sch.[schema_id]
WHERE si.[object_id] = object_id('test_history') 
	AND si.[index_id] > 1

--Note that you should use the column for DISABLE_STATEMENTS to disable the nonclustered indexes, 
--and be sure to keep the enable information handy because you’ll need it to rebuild the nonclustered indexes 
--after you’ve created the new clustered index.

--Disable any foreign key constraints. This is where you want to be careful if there are users using the database. In addition, this is also where you might want to use the following query to change the database to be restricted to only DBO use:
--ALTER DATABASE DatabaseName
--SET RESTRICTED_USER
--WITH ROLLBACK AFTER 5
--The ROLLBACK AFTER n clause at the end of the ALTER DATABASE statement lets you terminate user connections and put the database into a restricted state for modifications. As for automating the disabling of foreign key constraints, I leveraged some of the code from sp_fkeys and significantly altered it to generate the DISABLE command (similarly to how we did this in step 1 for disabling nonclustered indexes), which Listing 2 shows.

SELECT
    DISABLE_STATEMENT = 
		N'ALTER TABLE ' 
		+ QUOTENAME(convert(sysname, schema_name(o2.schema_id)), N']') 
		+ N'.'
		+ QUOTENAME(convert(sysname, o2.name), N']') 
		+ N' NOCHECK CONSTRAINT ' 
		+ QUOTENAME(convert(sysname, object_name(f.object_id)), N']')
    , ENABLE_STATEMENT =
		N'ALTER TABLE ' 
		+ QUOTENAME(convert(sysname, schema_name(o2.schema_id)), N']') 
		+ N'.'
		+ QUOTENAME(convert(sysname, o2.name), N']') 
		+ N' WITH CHECK CHECK CONSTRAINT ' 
		+ QUOTENAME(convert(sysname, object_name(f.object_id)), N']')
	, RECHECK_CONSTRAINT = 
		N'SELECT OBJECTPROPERTY(OBJECT_ID(' 
		+ QUOTENAME(convert(sysname, object_name(f.object_id)), N'''')
		+ N'), ''CnstIsNotTrusted'')'
FROM
    sys.objects AS o1,
    sys.objects AS o2,
    sys.columns AS c1,
    sys.columns AS c2,
    sys.foreign_keys AS f 
		INNER JOIN sys.foreign_key_columns AS k 
			ON (k.constraint_object_id = f.object_id) 
		INNER JOIN sys.indexes AS i 
			ON (f.referenced_object_id = i.object_id 
				AND f.key_index_id = i.index_id)
WHERE
    o1.[object_id] = object_id('test_history')
	AND i.name = 'Primary key Name' 
	AND o1.[object_id] = f.referenced_object_id
	AND o2.[object_id] = f.parent_object_id 
	AND c1.[object_id] = f.referenced_object_id 
	AND c2.[object_id] = f.parent_object_id 
	AND c1.column_id = k.referenced_column_id 
	AND c2.column_id = k.parent_column_id
ORDER BY 1, 2, 3

SELECT CONSTRAINT_NAME,
   TABLE_SCHEMA ,
   TABLE_NAME,
   CONSTRAINT_TYPE
   ,*
   FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	 WHERE 1=1
	 --and TABLE_NAME='FK__Contraint_col1'
	 and CONSTRAINT_NAME = 'FK__Contraint_col1'

-- no cascade
ALTER TABLE test_history_fk
ADD CONSTRAINT FK__Contraint_col11
FOREIGN KEY (col1) REFERENCES test_history (col1)
--ON UPDATE CASCADE
--ON DELETE CASCADE


ALTER TABLE test_history_fk
DROP CONSTRAINT FK__Contraint_col1

-- look for cascade action
SELECT name,delete_referential_action,delete_referential_action_desc,update_referential_action,
update_referential_action_desc
,*
,object_name(object_id) as K_Name
,object_name(referenced_object_id) as Parent_Table
,OBJECT_NAME(PARENT_OBJECT_ID) AS Parent_object
FROM sys.foreign_keys
where name ='FK__Contraint_col1'

-- very good way tp also index pk_name
EXEC sp_fkeys @pktable_name = N'test_history'  
    ,@pktable_owner = N'dbo';  


sp_helpindex test_history


--https://database.guide/11-ways-return-foreign-keys-sql-server-database-t-sql/

sp_helpindex N'Test_history'


EXEC sp_foreignkeys @table_server = N'Seattle1',   
   @pktab_name = N'Department',   
   @pktab_catalog = N'AdventureWorks2012';  


EXEC sp_primarykeys @table_server = N'LONDON1',   
   @table_name = N'JobCandidate',  
   @table_catalog = N'AdventureWorks2012',   
   @table_schema = N'HumanResources';  


-- Zmiana nazwy PK ktory jest czescia foreign key jakos to aktualizuje o dziwo
-- How to change pk_name in sp_fkeys?
-- How to change PK from NC to CL?
-- Create NC Place_holder as exact as OldCluster as index in needed 
-- Create CI drop_existing to prevent double index rebuild with data_comression=page with new definition
-- rename the index to NewName
-- CL(id) and NC(id) we have
-- PK nonclusterer still exists


