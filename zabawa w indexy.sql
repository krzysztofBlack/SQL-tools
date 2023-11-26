sp_spaceused ela

select * into ela_bis2 from ela

truncate table ela_bis2

sp_help ela_bis
sp_help ela_bis1

select MAX(id1) from ela
DBCC CHECKIDENT ('ela_bis', NORESEED )
, 6);
select IDENT_CURRENT('ela')

select IDENT_CURRENT('ela_bis1')

truncate table ela_bis1
DBCC CHECKIDENT ('ela_bis1', RESEED, 12166080);



use ksx

--select top 7 * from ela
--where (id1 >= 0 and id1 <= 3000) and name like '0003%'

set statistics io on

select object_id,Id1,type,type_desc,is_edge from ela
where 
(id1 >= 0 and id1 <= 3)
and object_id = 1

--update ela
--set object_id = 3 where id1 =3

/*
alter table ela add id bigint not null default 0

CREATE NONCLUSTERED INDEX [id2] ON [dbo].[ela]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-- Dodac identity
ALTER TABLE dbo.ela
ADD ID1 bigINT IDENTITY(1,1) not null

create unique clustered index CU_ela_id1 on dbo.ela (id1)

CREATE NONCLUSTERED INDEX [nc_ela-object_ID] ON [dbo].[ela]
(
	[object_id] ASC
)
INCLUDE([type],[type_desc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

GO

SELECT  Tab.name  Table_Name 
			 ,IX.name  Index_Name
			 ,IX.type_desc Index_Type
			 ,Col.name  Index_Column_Name
			 ,IXC.is_included_column Is_Included_Column
           FROM  sys.indexes IX 
           INNER JOIN sys.index_columns IXC  ON  IX.object_id   =   IXC.object_id AND  IX.index_id  =  IXC.index_id  
           INNER JOIN sys.columns Col   ON  IX.object_id   =   Col.object_id  AND IXC.column_id  =   Col.column_id     
           INNER JOIN sys.tables Tab      ON  IX.object_id = Tab.object_id
		   where Tab.name ='ela'


SELECT  OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name, 
IDX.name AS Index_Name, 
IDXPS.index_type_desc AS Index_Type, 
IDXPS.avg_fragmentation_in_percent  Fragmentation_Percentage
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS 
INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id 
AND IDX.index_id = IDXPS.index_id 
ORDER BY Fragmentation_Percentage DESC
*/

SELECT OBJECT_NAME(IX.OBJECT_ID) Table_Name
	   ,IX.name AS Index_Name
	   ,IX.type_desc Index_Type
	   ,SUM(PS.[used_page_count]) * 8 IndexSizeKB
	   ,IXUS.user_seeks AS NumOfSeeks
	   ,IXUS.user_scans AS NumOfScans
	   ,IXUS.user_lookups AS NumOfLookups
	   ,IXUS.user_updates AS NumOfUpdates
	   ,IXUS.last_user_seek AS LastSeek
	   ,IXUS.last_user_scan AS LastScan
	   ,IXUS.last_user_lookup AS LastLookup
	   ,IXUS.last_user_update AS LastUpdate
FROM sys.indexes IX
INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID,'IsUserTable') = 1
and OBJECT_NAME(IX.OBJECT_ID) = 'ela'
GROUP BY OBJECT_NAME(IX.OBJECT_ID) ,IX.name ,IX.type_desc ,IXUS.user_seeks ,IXUS.user_scans ,IXUS.user_lookups,IXUS.user_updates ,IXUS.last_user_seek ,IXUS.last_user_scan ,IXUS.last_user_lookup ,IXUS.last_user_update

