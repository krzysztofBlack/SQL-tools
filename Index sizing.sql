use ksx

CREATE CLUSTERED INDEX [id1] ON [dbo].[ela]
(
	[object_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-- This command affects clustered index
ALTER TABLE dbo.ela
REBUILD PARTITION = ALL WITH (MAXDOP=2,DATA_COMPRESSION =  Row) ;  

sp_spaceused ela

-- Page
ela	12166080            	1.115.688 KB	414.512 KB	698952 KB	2224 KB
-- Row
ela	12166080            	2.387.560 KB	1.683.320 KB	701904 KB	2336 KB
--None
ela	12166080            	3.745.512 KB	3.037.408 KB	705920 KB	2184 KB
--CL COLUMNSTORE
ela	12166080            	423.000 KB		5.256 KB		416968 KB	776 KB

select * from sys.indexes
where name like 'id1'

SELECT 
OBJECT_NAME(i.object_id),
i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
GROUP BY OBJECT_NAME(i.object_id), i.[name]
ORDER BY OBJECT_NAME(i.object_id), i.[name]
GO

-- Ensure a USE  statement has been executed first.
SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,[AvgFragmentationInPercent]
FROM (
    SELECT DISTINCT DB_Name(Database_id) AS 'DatabaseName'
        ,OBJECT_ID AS ObjectId
        ,Object_Name(Object_id) AS ObjectName
        ,Index_ID AS IndexId
        ,Index_Type_Desc AS IndexDescription
        ,avg_record_size_in_bytes
        ,record_count
        ,STATS_DATE(object_id, index_id) AS 'lastupdated'
        ,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS 'AvgFragmentationInPercent'
    FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'detailed')
    WHERE OBJECT_ID IS NOT NULL
        AND Avg_Fragmentation_In_Percent <> 0
    ) T
GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
    ,IndexDescription
    ,lastupdated
    ,AvgFragmentationInPercent


