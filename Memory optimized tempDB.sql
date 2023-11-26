



/*
ostress.exe -Slocalhost,1455 -Usa -PP@ssw0rd!  -dAdventureWorks -Q"EXEC dbo.usp_EmployeeBirthdayList 4"  -mstress -quiet -n20 -r120 | FINDSTR "QEXEC Starting Creating elapsed"
*/

dbcc memorystatus
go

SELECT * FROM SYS.dm_os_sys_info
-- Committed_KB
-- Committed_target_KB
-- Witajcie w naszej bajce, słoń zagra na fujarce 
--Pinokio Wam zaspiewa zatancza wkoło drzewa, tu wszystko jest możliwe nie zawsze sprawiedliwe


select 2976696/1024

SELECT 
er.session_id, er.wait_type, er.wait_resource, 
OBJECT_NAME(page_info.[object_id],page_info.database_id) as [object_name],
er.blocking_session_id,er.command, 
    SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
        ((CASE er.statement_end_offset  
          WHEN -1 THEN DATALENGTH(st.text)  
         ELSE er.statement_end_offset  
         END - er.statement_start_offset)/2) + 1) AS statement_text,
page_info.database_id,page_info.[file_id], page_info.page_id, page_info.[object_id], 
page_info.index_id, page_info.page_type_desc
FROM sys.dm_exec_requests AS er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st 
CROSS APPLY sys.fn_PageResCracker (er.page_resource) AS r  
CROSS APPLY sys.dm_db_page_info(r.[db_id], r.[file_id], r.page_id, 'DETAILED') AS page_info
WHERE er.wait_type like '%page%'
GO


ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA=ON;
GO

SELECT SERVERPROPERTY('IsTempDBMetadataMemoryOptimized') AS IsTempDBMetadataMemoryOptimized; 
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'tempdb metadata memory-optimized'

/*
USE [master]
RESTORE DATABASE [AdventureWorks] FROM  DISK = N'D:\SQL_TMP\AdventureWorks2017.bak' 
WITH  FILE = 1,  
		MOVE N'AdventureWorks2017' TO N'C:\SQL\DATA\AdventureWorks.mdf',  
		MOVE N'AdventureWorks2017_log' TO N'C:\SQL\DATA\AdventureWorks_log.ldf',  NOUNLOAD
GO

USE AdventureWorks
GO

CREATE OR ALTER PROCEDURE usp_EmployeeBirthdayList @month int AS
BEGIN

	IF OBJECT_ID('tempdb..#Birthdays') IS NOT NULL DROP TABLE #Birthdays;

	CREATE TABLE #Birthdays (BusinessEntityID int NOT NULL PRIMARY KEY);

	INSERT #Birthdays (BusinessEntityID)
	SELECT BusinessEntityID
	FROM HumanResources.Employee 
	WHERE MONTH(BirthDate) = @month

	SELECT p.FirstName, p.LastName, a.AddressLine1, a.AddressLine2, a.City, sp.StateProvinceCode, a.PostalCode
	FROM #Birthdays b
	INNER JOIN Person.Person p ON b.BusinessEntityID = p.BusinessEntityID
	INNER JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
	INNER JOIN Person.Address a ON bea.AddressID = a.AddressID
	INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
	INNER JOIN Person.AddressType at ON at.AddressTypeID = bea.AddressTypeID
	WHERE at.Name = N'Home'

END;
*/


