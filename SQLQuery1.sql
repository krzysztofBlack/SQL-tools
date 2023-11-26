USE ksx


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
SELECT o.object_id, REPLICATE('z',1000)
FROM sys.objects o, sys.objects o1, sys.objects o2;
GO 5