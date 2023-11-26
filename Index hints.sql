	
USE AdventureWorks
GO

SELECT c.ContactID
FROM Person.Contact c
INNER JOIN Person.Contact pc
ON c.ContactID = pc.ContactID
OPTION (TABLE HINT(c, INDEX (AK_Contact_rowguid)), TABLE HINT(pc, INDEX (PK_Contact_ContactID)))
GO

CREATE INDEX r 
    ON dbo.Users(Reputation) 
WITH(MAXDOP = 8, SORT_IN_TEMPDB = ON);
CREATE INDEX c 
    ON dbo.Users(CreationDate) 
WITH(MAXDOP = 8, SORT_IN_TEMPDB = ON);

DECLARE @Reputation int = 2;
EXEC sp_executesql N'SELECT * FROM dbo.Users WITH (INDEX  = c) WHERE Reputation = @Reputation;',
                   N'@Reputation int',
                   @Reputation;


EXEC sp_create_plan_guide
@name = N'dammit',
@stmt = N'SELECT * FROM dbo.Users WITH (INDEX  = c) WHERE Reputation = @Reputation;',
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@Reputation int',
@hints =  N'OPTION(TABLE HINT(dbo.Users))';

EXEC sp_create_plan_guide
@name = N'dammit',
@stmt = N'SELECT u.* FROM dbo.Users AS u WITH (INDEX  = c) WHERE u.Reputation = @Reputation;',
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@Reputation int',
@hints =  N'OPTION(TABLE HINT(u))';


