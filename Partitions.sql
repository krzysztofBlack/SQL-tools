USE [ksx]
GO

BEGIN TRANSACTION
CREATE PARTITION FUNCTION [fn_part](bigint) AS RANGE LEFT FOR VALUES (N'1000', N'2000', N'3000', N'4000', N'5000')


CREATE PARTITION SCHEME [fn_schem] AS PARTITION [fn_part] TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])

CREATE CLUSTERED INDEX [cl_1] ON [dbo].[t1a]
(
	[Col1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [fn_schem]([Col1])

COMMIT TRANSACTION


SELECT * INTO T1B
FROM DBO.t1a


SELECT OBJECT_NAME(sp.object_id) AS tableName,
       sp.partition_number as partitionNumber,
	  sp.rows,*
FROM sys.partitions AS sp
--left join sys.indexes I ON sp.object_id = i.object_id and sp.index_id = I.index_id   
WHERE sp.object_id IN(OBJECT_ID('dbo.ela1'), OBJECT_ID('dbo.T1A'))
order by 1,6

