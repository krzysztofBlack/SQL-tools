
use tempdb
go

-- Refresh intellisence Use the CTRL+Shift+R keyboard shortcut.
-- ctrl+J List members

-- ctrl Shift space parameter info

-- ctrl+k, ctrl+I  quick info show select * list of fields amazing!

-- ctrl space - complete word

-- ctrl shift U - upper case
-- ctrl K ctrl S - Surround with !!!
-- ctrl K ctrl X - insert snippet

--ctrl G go to line

use alt to enable vertical editing in management studio
crtl I
\n \t 
ctrl H

You can edit selection and replace in management studio


SELECT ela.
from dbo.ela;

use ksx

SELECT ela.history_retention_period_unit, ela.type
, 
from ela


if exists (select * from sys.objects where name = 'sqlws_xev_query_post_execution_showplan')
    drop view sqlws_xev_query_post_execution_showplan
go
create view sqlws_xev_query_post_execution_showplan as
with xevents (event_data)
as
(
    select event.query('.') as event_data from 
        ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_query_post_execution_showplan' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="query_post_execution_showplan"]') as x (event))
)
select event_data.value ('(event/@name)[1]', 'varchar(max)') as event_name,
    event_data.value ('(event/@timestamp)[1]', 'datetime') as event_timestamp,
    event_data.value ('(event/data[@name="source_database_id"]/value)[1]', 'bigint') as [source_database_id],
    event_data.value ('(event/data[@name="object_type"]/value)[1]', 'int') as [object_type],
    (select map_value from sys.dm_xe_map_values xemv where xemv.object_package_guid = '03FDA7D0-91BA-45F8-9875-8B6DD0B8E9F2' and xemv.name = 'object_type' and xemv.map_key = event_data.value ('(event/data[@name="object_type"]/value)[1]', 'int')) as [object_type_map_value],
    event_data.value ('(event/data[@name="object_id"]/value)[1]', 'int') as [object_id],
    event_data.value ('(event/data[@name="nest_level"]/value)[1]', 'int') as [nest_level],
    event_data.value ('(event/data[@name="cpu_time"]/value)[1]', 'bigint') as [cpu_time],
    event_data.value ('(event/data[@name="duration"]/value)[1]', 'bigint') as [duration],
    event_data.value ('(event/data[@name="estimated_rows"]/value)[1]', 'int') as [estimated_rows],
    event_data.value ('(event/data[@name="estimated_cost"]/value)[1]', 'int') as [estimated_cost],
    event_data.value ('(event/data[@name="serial_ideal_memory_kb"]/value)[1]', 'bigint') as [serial_ideal_memory_kb],
    event_data.value ('(event/data[@name="requested_memory_kb"]/value)[1]', 'bigint') as [requested_memory_kb],
    event_data.value ('(event/data[@name="used_memory_kb"]/value)[1]', 'bigint') as [used_memory_kb],
    event_data.value ('(event/data[@name="ideal_memory_kb"]/value)[1]', 'bigint') as [ideal_memory_kb],
    event_data.value ('(event/data[@name="granted_memory_kb"]/value)[1]', 'bigint') as [granted_memory_kb],
    event_data.value ('(event/data[@name="dop"]/value)[1]', 'bigint') as [dop],
    event_data.value ('(event/data[@name="object_name"]/value)[1]', 'nvarchar(max)') as [object_name],
    event_data.query ('(event/data[@name="showplan_xml"]/value)[1]/node()') as [showplan_xml],
    event_data.value ('(event/data[@name="database_name"]/value)[1]', 'nvarchar(max)') as [database_name],
    event_data.value ('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(max)') as action_client_app_name,
    event_data.value ('(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)') as action_client_hostname,
    event_data.value ('(event/action[@name="database_name"]/value)[1]', 'nvarchar(max)') as action_database_name,
    event_data.value ('(event/action[@name="nt_username"]/value)[1]', 'nvarchar(max)') as action_nt_username,
    event_data.value ('(event/action[@name="session_id"]/value)[1]', 'int') as action_session_id,
    event_data.value ('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as action_sql_text
    from xevents
go

--SQL Server Extended Events script provided by Ramesh Meyyappan (mailto:rmeyyappan@sqlworkshops.com), SQL Consulting GmbH, Munich, Germany, http://www.sqlworkshops.com. Copyright: 2011-2016 Ramesh Meyyappan.
--Please email your comments, feedback and suggestions to Ramesh @ mailto:rmeyyappan@sqlworkshops.com, keep yourself up to date by subscribing to our newsletter at https://newsletter.sqlworkshops.com. Connect with me in LinkedIn: http://de.linkedin.com/in/rmeyyappan, on twitter https://twitter.com/SQLWorkshops.
--This SQL Server Extended Events script is provided to you under "Free Community License" model, Please read the EULA for additional information @ www.sqlvideo.com/eula. You acknowledge upon downloading or using the SQL Server Extended Events script that you have reviewed and agreed to all of the terms and conditions set forth in the EULA (http://www.sqlvideo.com/eula).
--About Us: We are a consulting company, SQL Consulting GmbH, based in Munich, Germany. We provide onsite and offsite SQL Server Performance Tuning and Troubleshooting Consulting. Please contact us at mailto:support@sqlworkshops.com or visit http://www.sqlworkshops.com if you are interested in any of our services.
--Download SQLTest, our SQL Server Performance, Load, Stress and Unit Test Tool from http://www.sqltest.org.
--Download sp_whopro(TM) script, our SQL Server Activity Monitoring and Logging Stored Procedure from http://www.sqldownload.com.
--Checkout our SQL Server Videos: http://www.sqlvideo.com

if exists (select * from sys.server_event_sessions where name = 'sqlws_xevents_query_post_execution_showplan')
    drop event session sqlws_xevents_query_post_execution_showplan on server
go
create event session sqlws_xevents_query_post_execution_showplan on server
    add event sqlserver.query_post_execution_showplan (action (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_name, sqlserver.nt_username, sqlserver.session_id, sqlserver.sql_text) where cpu_time >= 1000000 and counter <= 100)
    add target package0.ring_buffer 
    with (event_retention_mode = ALLOW_SINGLE_EVENT_LOSS, memory_partition_mode = NONE)
go

/*
alter event session sqlws_xevents_query_post_execution_showplan on server state = start
go

--Execute your workload

with xevents (event_name)
as
(
    select event.value ('(@name)[1]', 'varchar(max)') as event_name
        from ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_query_post_execution_showplan' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="query_post_execution_showplan"]') as x (event))
)
select event_name, count(*) from xevents
    group by event_name
go

select * from sqlws_xev_query_post_execution_showplan
go

alter event session sqlws_xevents_query_post_execution_showplan on server state = start
go

*/

--------------------------------------------------------------------------
-- Drugie

use tempdb
go
if exists (select * from sys.objects where name = 'sqlws_xev_xml_deadlock_report')
    drop view sqlws_xev_xml_deadlock_report
go

create view sqlws_xev_xml_deadlock_report as
with xevents (event_data)
as
(
    select event.query('.') as event_data from 
        ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_xml_deadlock_report' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="xml_deadlock_report"]') as x (event))
)
select event_data.value ('(event/@name)[1]', 'varchar(max)') as event_name,
    event_data.value ('(event/@timestamp)[1]', 'datetime') as event_timestamp,
    event_data.query ('(event/data[@name="xml_report"]/value)[1]/node()') as [xml_report],
    event_data.value ('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(max)') as action_client_app_name,
    event_data.value ('(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)') as action_client_hostname,
    event_data.value ('(event/action[@name="database_name"]/value)[1]', 'nvarchar(max)') as action_database_name,
    event_data.value ('(event/action[@name="nt_username"]/value)[1]', 'nvarchar(max)') as action_nt_username,
    event_data.value ('(event/action[@name="session_id"]/value)[1]', 'int') as action_session_id,
    event_data.value ('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as action_sql_text
    from xevents
go

--SQL Server Extended Events script provided by Ramesh Meyyappan (mailto:rmeyyappan@sqlworkshops.com), SQL Consulting GmbH, Munich, Germany, http://www.sqlworkshops.com. Copyright: 2011-2016 Ramesh Meyyappan.
--Please email your comments, feedback and suggestions to Ramesh @ mailto:rmeyyappan@sqlworkshops.com, keep yourself up to date by subscribing to our newsletter at https://newsletter.sqlworkshops.com. Connect with me in LinkedIn: http://de.linkedin.com/in/rmeyyappan, on twitter https://twitter.com/SQLWorkshops.
--This SQL Server Extended Events script is provided to you under "Free Community License" model, Please read the EULA for additional information @ www.sqlvideo.com/eula. You acknowledge upon downloading or using the SQL Server Extended Events script that you have reviewed and agreed to all of the terms and conditions set forth in the EULA (http://www.sqlvideo.com/eula).
--About Us: We are a consulting company, SQL Consulting GmbH, based in Munich, Germany. We provide onsite and offsite SQL Server Performance Tuning and Troubleshooting Consulting. Please contact us at mailto:support@sqlworkshops.com or visit http://www.sqlworkshops.com if you are interested in any of our services.
--Download SQLTest, our SQL Server Performance, Load, Stress and Unit Test Tool from http://www.sqltest.org.
--Download sp_whopro(TM) script, our SQL Server Activity Monitoring and Logging Stored Procedure from http://www.sqldownload.com.
--Checkout our SQL Server Videos: http://www.sqlvideo.com

if exists (select * from sys.server_event_sessions where name = 'sqlws_xevents_xml_deadlock_report')
    drop event session sqlws_xevents_xml_deadlock_report on server
go

create event session sqlws_xevents_xml_deadlock_report on server
    add event sqlserver.xml_deadlock_report (action (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_name, sqlserver.nt_username, sqlserver.session_id, sqlserver.sql_text) where counter <= 100)
    add target package0.ring_buffer 
    with (event_retention_mode = ALLOW_SINGLE_EVENT_LOSS, memory_partition_mode = NONE)
go

/*
alter event session sqlws_xevents_xml_deadlock_report on server state = start
go

--Execute your workload

with xevents (event_name)
as
(
    select event.value ('(@name)[1]', 'varchar(max)') as event_name
        from ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_xml_deadlock_report' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="xml_deadlock_report"]') as x (event))
)
select event_name, count(*) from xevents
    group by event_name
go

select * from sqlws_xev_xml_deadlock_report
go

alter event session sqlws_xevents_xml_deadlock_report on server state = stop
go
*/


--------------------------------------------
use tempdb
go
if exists (select * from sys.objects where name = 'sqlws_xev_locks_lock_waits')
    drop view sqlws_xev_locks_lock_waits
go
create view sqlws_xev_locks_lock_waits as
with xevents (event_data)
as
(
    select event.query('.') as event_data from 
        ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_locks_lock_waits' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="locks_lock_waits"]') as x (event))
)
select event_data.value ('(event/@name)[1]', 'varchar(max)') as event_name,
    event_data.value ('(event/@timestamp)[1]', 'datetime') as event_timestamp,
    event_data.value ('(event/data[@name="count"]/value)[1]', 'bigint') as [count],
    event_data.value ('(event/data[@name="increment"]/value)[1]', 'bigint') as [increment],
    event_data.value ('(event/data[@name="lock_type"]/value)[1]', 'bigint') as [lock_type],
    event_data.value ('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(max)') as action_client_app_name,
    event_data.value ('(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)') as action_client_hostname,
    event_data.value ('(event/action[@name="database_name"]/value)[1]', 'nvarchar(max)') as action_database_name,
    event_data.value ('(event/action[@name="nt_username"]/value)[1]', 'nvarchar(max)') as action_nt_username,
    event_data.value ('(event/action[@name="session_id"]/value)[1]', 'int') as action_session_id,
    event_data.value ('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as action_sql_text
    from xevents
go

--SQL Server Extended Events script provided by Ramesh Meyyappan (mailto:rmeyyappan@sqlworkshops.com), SQL Consulting GmbH, Munich, Germany, http://www.sqlworkshops.com. Copyright: 2011-2016 Ramesh Meyyappan.
--Please email your comments, feedback and suggestions to Ramesh @ mailto:rmeyyappan@sqlworkshops.com, keep yourself up to date by subscribing to our newsletter at https://newsletter.sqlworkshops.com. Connect with me in LinkedIn: http://de.linkedin.com/in/rmeyyappan, on twitter https://twitter.com/SQLWorkshops.
--This SQL Server Extended Events script is provided to you under "Free Community License" model, Please read the EULA for additional information @ www.sqlvideo.com/eula. You acknowledge upon downloading or using the SQL Server Extended Events script that you have reviewed and agreed to all of the terms and conditions set forth in the EULA (http://www.sqlvideo.com/eula).
--About Us: We are a consulting company, SQL Consulting GmbH, based in Munich, Germany. We provide onsite and offsite SQL Server Performance Tuning and Troubleshooting Consulting. Please contact us at mailto:support@sqlworkshops.com or visit http://www.sqlworkshops.com if you are interested in any of our services.
--Download SQLTest, our SQL Server Performance, Load, Stress and Unit Test Tool from http://www.sqltest.org.
--Download sp_whopro(TM) script, our SQL Server Activity Monitoring and Logging Stored Procedure from http://www.sqldownload.com.
--Checkout our SQL Server Videos: http://www.sqlvideo.com

if exists (select * from sys.server_event_sessions where name = 'sqlws_xevents_locks_lock_waits')
    drop event session sqlws_xevents_locks_lock_waits on server
go
create event session sqlws_xevents_locks_lock_waits on server
    add event sqlserver.locks_lock_waits (action (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_name, sqlserver.nt_username, sqlserver.session_id, sqlserver.sql_text) where increment >= 1000 and counter <= 100)
    add target package0.ring_buffer 
    with (event_retention_mode = ALLOW_SINGLE_EVENT_LOSS, memory_partition_mode = NONE)
go

/*
alter event session sqlws_xevents_locks_lock_waits on server state = start
go

--Execute your workload

with xevents (event_name)
as
(
    select event.value ('(@name)[1]', 'varchar(max)') as event_name
        from ((select cast (xest.target_data as xml) as target_data
                from sys.dm_xe_sessions as xes
                inner join sys.dm_xe_session_targets as xest on (xes.address = xest.event_session_address)
                where xes.name = 'sqlws_xevents_locks_lock_waits' and xest.target_name = 'ring_buffer') as td
            cross apply target_data.nodes ('//event[@name="locks_lock_waits"]') as x (event))
)
select event_name, count(*) from xevents
    group by event_name
go

select * from sqlws_xev_locks_lock_waits
go


alter event session sqlws_xevents_locks_lock_waits on server state = stop
go
*/

select top 100 * from ela where object_id  = 3

update ela
set type_desc = 'Beksa1_1'
where object_id = 3

use [ksx]

begin transaction

--select top 100 * from ela

update ela
set type_desc = 'Beksa'
where object_id = 3

rollback






