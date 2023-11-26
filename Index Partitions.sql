
SELECT OBJECT_NAME(sp.object_id) AS tableName,
       sp.partition_number as partitionNumber,
	  sp.rows,*
FROM sys.partitions AS sp
--left join sys.indexes I ON sp.object_id = i.object_id and sp.index_id = I.index_id   
WHERE sp.object_id IN(OBJECT_ID('dbo.ela1'), OBJECT_ID('dbo.ela'))
order by 1,6

SELECT OBJECT_NAME(sp.object_id) AS tableName,
       sp.partition_number as partitionNumber,
	  sp.rows, i.name, i.type_desc, sp.*, I.*
FROM sys.partitions AS sp
left join sys.indexes I ON sp.object_id = i.object_id and sp.index_id = I.index_id   
WHERE sp.object_id IN(OBJECT_ID('dbo.ela1'), OBJECT_ID('dbo.ela'))
order by 1,6


select index_id, name, * from sys.indexes where object_id = OBJECT_ID('ela')

select COUNT(*) from T1A
select top 100 * from t1a

-- Adding new unique id1
DECLARE @id bigINT 
SET @id = 0 
UPDATE T1A
SET @id = Col1 = @id + 1 
GO 

ALTER TABLE MyTable ADD MyColumn int IDENTITY(1, 2) NOT NULL
