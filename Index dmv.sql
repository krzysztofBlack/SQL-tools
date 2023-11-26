use msdb

sp_whoisactive

use ksx

select * from sys.dm_db_index_usage_stats

select * from sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_operational_stats( NULL, NULL, NULL, NULL);    



sp_blitzfirst @expertmode=1

sp_configure 'remote admin',1
reconfigure
-- select * into ksx.dbo.ela from sys.tables

use ksx

sp_helpindex ela

select * from sys.dm_db_index_physical_stats


insert into ela
select * from msdb.sys.tables
go 2000


select * into ksx.dbo.ela from sys.tables
sp_who2

set nocount on

select count(*) tola from ela where name like '%kids%'

set statistics io,time on
update ela set NAME = NEWID() where name like '%mi%'
go 1000

Database [ksx] has auto-update-stats-async enabled.  When SQL Server gets a query for a table with out-of-date statistics, 
it will run the query with the stats it has - while updating stats to make later queries better. 
The initial run of the query may suffer, though.
