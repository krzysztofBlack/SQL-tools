/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Col1]
      ,[Col2_test]
      ,[id]
      ,[id1]
      ,[x1]
      ,[id2]
      ,[x1t]
-- into dbo.Try1
 FROM [ksx1].[dbo].[t1c]


 SELECT * FROM TRY1

 UPDATE TRY1 
 SET ID1= 1000
 WHERE ID > 19726 AND ID <= 197268

 DELETE FROM TRY1 
 WHERE ID > 19725 


 -- https://royalsql.com/2022/10/25/transactions-follow-me-left-and-right-but-who-did-that-over-here/

 -- Main search
 SELECT [Current LSN]
		,[Operation]
		,[Context]
		,[Transaction ID]
		,[Description]
		,[Begin Time]
		,[Transaction SID]
FROM fn_dblog (NULL,NULL)
INNER JOIN(SELECT [Transaction ID] AS tid
FROM fn_dblog(NULL,NULL)
WHERE [Transaction Name] LIKE '%SET ID1= 1000%')fd ON [Transaction ID] = fd.tid


SELECT [Current LSN]
		,[Operation]
		,[Context]
		,[Transaction ID]
		,[Description]
		,[Begin Time]
		,[Transaction SID]
		,SUSER_SNAME ([Transaction SID]) AS WhoDidIt
FROM fn_dblog (NULL,NULL)
INNER JOIN(SELECT [Transaction ID] AS tid
FROM fn_dblog(NULL,NULL)
WHERE [Transaction Name] LIKE 'create index%')fd ON [Transaction ID] = fd.tid


