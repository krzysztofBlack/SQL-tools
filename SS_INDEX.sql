
sp_spaceused t1a

select * from t1c

CREATE UNIQUE CLUSTERED INDEX [i2] ON [dbo].[t1c]
(
	[Col1],IDX ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
IGNORE_DUP_KEY = OFF, DROP_EXISTING = On, ONLINE = On, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


sp_help t1c

ALTER TABLE T1C
   ADD CONSTRAINT PK_1 PRIMARY KEY NONCLUSTERED (IDX);

ALTER TABLE T1C
   ADD CONSTRAINT PK_1A UNIQUE NONCLUSTERED (IDX);



CREATE UNIQUE CLUSTERED INDEX I2 

ALTER TABLE T1C
ADD IDX BIGINT NOT NULL DEFAULT 0

UPDATE T1C 
SET IDX = COL1
