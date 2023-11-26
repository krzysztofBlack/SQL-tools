/*--------------------------------------------------------
-- Zamiana constraints oraz primary key nonclustered in clustered
-- Jak mamy primary key NC A oraz Clustered index B inny to 

 NCU_nazwa_ks
 CU_nazwa_Hks (od place holder)
 CPK
 NPK

1. Tworzymy NC_B_HKS
2. rename Clustered_R
3. create index  drop_existing with page id na identity
4. Jak malo miejsca do robimy alter index NC na page compression, 
5. sort in tempdb, bulk load, delayed durability, 
6. create login U_Maintenance, dajemy jako job, resourse governor, io_physical stats, resumable, log backup, ADR, AlwaysON pause albo Async
7. albo execute As U_maintenance
8. low priorrity blockers! 
9. patrzymy czy mamy constraints czy indexy bo trzeba zamienic 1Two1
10. Tworzymy w transakcji set lock timeout 
11 Nowy constraint foreign key 
12. Primary key clustered zaczynamy od history tables
13. Mozna tez disable index a potem rebuild szczegolnie tych indexow, ktore sa unsused. Mozna unused wywalic po prostu
14. tworzymy nowy constaint w transakcji aby foreign key wskazywal na nowy index clustered
15 tabela bez indeksow tez moze tez byc page
16 nowy constraint moze byc nocheck bo wtedy szybciej sie zaklada
17. skoro mamy PK NC na identity , oraz UCI na identity to czy warto zmieniac PK i czy wtedy jest page contenion?
18. Zak









----------------------------------------------------------*/
USE ksx
drop table if exists chapters

CREATE TABLE books1
(
id INT  
CONSTRAINT PK_books_id PRIMARY KEY CLUSTERED (id) not null,
name VARCHAR(50) NOT NULL,
category VARCHAR(50) NOT NULL,
price INT NOT NULL
)

INSERT INTO books1
VALUES
(1, 'chapter1', 'Cat1', 1800 ),
(2, 'chapter2', 'Cat2', 1500 ),
(3, 'chapter3', 'Cat3', 2000 ),
(4, 'chapter1', 'Cat4', 1300 ),
(5, 'chapter2', 'Cat5', 1500 ),
(6, 'chapter1', 'Cat6', 5000),
(7, 'chapter2', 'Cat7', 8000),
(8, 'chapter3', 'Cat8', 5000),
(9, 'chapter1', 'Cat9', 5400),
(10, 'chapter2', 'Cat10', 3200)

alter table books 
drop constraint PK_books_id_renamed

alter table books1 
drop constraint PK_books_id

alter table books1 
drop constraint CU_books_id_1

-- create new constraints 
sp_helpindex 'books1';
go
sp_helpindex 'books';

drop index pk_books_id_renamed on books

CREATE TABLE chapters
(
id INT  
CONSTRAINT PK_chapters_id PRIMARY KEY CLUSTERED (id) not null,
name VARCHAR(50) NOT NULL,
category VARCHAR(50) NOT NULL,
price INT NOT NULL,
id_books int not null
)

INSERT INTO chapters
VALUES
(1, 'chapter1', 'Cat1', 1800,1),
(2, 'chapter2', 'Cat2', 1500,1),
(3, 'chapter3', 'Cat3', 2000,1),
(4, 'chapter1', 'Cat4', 1300,2),
(5, 'chapter2', 'Cat5', 1500,2),
(6, 'chapter1', 'Cat6', 5000,3),
(7, 'chapter2', 'Cat7', 8000,3),
(8, 'chapter3', 'Cat8', 5000,3),
(9, 'chapter1', 'Cat9', 5400,4),
(10, 'chapter2', 'Cat10', 3200,4)

drop index ix_1 on books
drop index ix_3 on books

drop index c_books_id1 on books

EXECUTE sp_helpindex Books
EXECUTE sp_helpindex Books1

EXECUTE sp_helpindex chapters

ALTER TABLE dbo.chapters
   ADD CONSTRAINT FK_books FOREIGN KEY (id_books)
      REFERENCES dbo.books (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;
-- How to force SQL to use the index I want?
/*
Have NC primary Key
Have Clustered Key I want to change to NC
Priamy Key is refenced by foreign key constraint

Steps1
Create place holder for NC index = Clustered key definition
Created index drop_existing=ON with my new index definition on ID identity
Rename the index to the one I like
what if those are constraints
do begin transaction drop contraint, drop index NC, create contraint which is quick



*/

ALTER TABLE dbo.chapters
   drop CONSTRAINT FK_books 
 


ALTER TABLE dbo.chapters
   ADD CONSTRAINT FK_books1 FOREIGN KEY (id_books)
      REFERENCES dbo.books1 (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;

ALTER TABLE dbo.books
add CONSTRAINT PKNC_books_id_ PRIMARY KEY NONCLUSTERED (id) ;


ALTER TABLE dbo.books
add CONSTRAINT PK_books_id_renamed PRIMARY KEY CLUSTERED (id) ;

ALTER TABLE dbo.books1
add CONSTRAINT CU_books_id_1 unique NONCLUSTERED (id) ;

ALTER TABLE dbo.books1
add CONSTRAINT CU_books_id_2 unique NONCLUSTERED (id) ;


SELECT   
    f.name AS foreign_key_name  
   ,OBJECT_NAME(f.parent_object_id) AS table_name  
   ,COL_NAME(fc.parent_object_id, fc.parent_column_id) AS constraint_column_name  
   ,OBJECT_NAME (f.referenced_object_id) AS referenced_object  
   ,COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS referenced_column_name  
   ,f.is_disabled  
   ,f.delete_referential_action_desc  
   ,f.update_referential_action_desc  
   ,f.key_index_id
   ,X.name as IndexName
   ,object_name(f.referenced_object_id)
 FROM sys.foreign_keys AS f  
INNER JOIN sys.foreign_key_columns AS fc   
   ON f.object_id = fc.constraint_object_id  
left JOIN sys.indexes X on (X.object_id = f.referenced_object_id and f.key_index_id = x.index_id) 
WHERE f.parent_object_id = OBJECT_ID('dbo.chapters');  

--select * from sys.foreign_keys
--select * from sys.foreign_key_columns
select OBJECT_NAME(object_id), * from sys.indexes where OBJECT_NAME(object_id) like 'Books%'




select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
    '>-' as rel,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table,
    substring(column_names, 1, len(column_names)-1) as [fk_columns],
    fk.name as fk_constraint_name
from sys.foreign_keys fk
    inner join sys.tables fk_tab
        on fk_tab.object_id = fk.parent_object_id
    inner join sys.tables pk_tab
        on pk_tab.object_id = fk.referenced_object_id
    cross apply (select col.[name] + ', '
                    from sys.foreign_key_columns fk_c
                        inner join sys.columns col
                            on fk_c.parent_object_id = col.object_id
                            and fk_c.parent_column_id = col.column_id
                    where fk_c.parent_object_id = fk_tab.object_id
                      and fk_c.constraint_object_id = fk.object_id
                            order by col.column_id
                            for xml path ('') ) D (column_names)
order by schema_name(fk_tab.schema_id) + '.' + fk_tab.name,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name

drop index ix_1 on books
--An explicit DROP INDEX is not allowed on index 'books.ix_1'. It is being used for FOREIGN KEY constraint enforcement.

CREATE UNIQUE NONCLUSTERED INDEX IX_3
ON Books(ID ASC)

CREATE UNIQUE NONCLUSTERED INDEX IX_1
ON Books(ID ASC)
with (drop_existing = on)


ALTER TABLE Books
DROP CONSTRAINT PK__Books__3213E83F6C2AB808
with (online=on)

alter table books 
add constraint c_books_id1 unique nonclustered (id asc) 
with (online=on);

alter table books 
add constraint c_books_id2 unique nonclustered (id asc) 
with (online=on);



ALTER TABLE Persons
ADD CONSTRAINT PK_Person PRIMARY KEY (ID,LastName);

create index c_books_id1

SELECT name, SCHEMA_NAME(schema_id) AS schema_name, type_desc  
,*
FROM sys.objects  
WHERE parent_object_id = (OBJECT_ID('books'))   
--AND type IN ('C','F', 'PK');   
GO  

select object_name(1330103779), OBJECT_NAME(1314103722)
  
--EXEC sp_rename N'Purchasing.ProductVendor.IX_ProductVendor_VendorID', N'IX_VendorID', N'INDEX';  
GO


chapters_PK

EXEC sp_rename N'schema.MyIOldConstraint', N'MyNewConstraint', N'OBJECT'
-- Rename the primary key constraint.  
sp_rename 'dbo.PK__chapters__3213E83F7F61D4D1', 'PK_books_id';  
GO  
  
-- Rename a check constraint.  
sp_rename 'HumanResources.CK_Employee_BirthDate', 'CK_BirthDate';  
GO  

EXEC sp_rename N'dbo.pk_books_id', N'c_books_id1', N'OBJECT'

EXEC sp_rename N'dbo.c_books_id2', N'c_books_id2_renamed', N'OBJECT'

EXEC sp_rename N'dbo.PK_books_id', N'PK_books_id_renamed', N'OBJECT'

name	schema_name	type_desc	name	object_id	principal_id	schema_id	parent_object_id	type	type_desc	create_date	modify_date	is_ms_shipped	is_published	is_schema_published
PK_books_id	dbo	PRIMARY_KEY_CONSTRAINT	PK_books_id	1330103779	NULL	1	1314103722	PK	PRIMARY_KEY_CONSTRAINT	2022-03-19 16:39:09.447	2022-03-19 17:18:31.803	0	0	0
c_books_id1	dbo	UNIQUE_CONSTRAINT	c_books_id1	1346103836	NULL	1	1314103722	UQ	UNIQUE_CONSTRAINT	2022-03-19 16:55:21.973	2022-03-19 16:55:21.973	0	0	0
c_books_id2	dbo	UNIQUE_CONSTRAINT	c_books_id2	1362103893	NULL	1	1314103722	UQ	UNIQUE_CONSTRAINT	2022-03-19 16:57:25.097	2022-03-19 16:57:25.097	0	0	0
