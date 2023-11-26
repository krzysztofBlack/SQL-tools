
:setvar lserver "DESKTOP-HN8MK56\SQL1"
:setvar lWyn "Result"
:setVar lcmd "select @@servername, getdate()"


:connect $(lserver) 

$(lcmd)
go


:connect $(lserver) 

$(lcmd)
go

:connect $(lserver) 

$(lcmd)
go


/*






select 
go


:connect DESKTOP-HN8MK56\SQL1





declare @lRes char(300) 
set @lRes = ''

declare @lRes1 char(300) 
set @lRes1 = ''

USE ksx;
set @lres = (select @@servername)


set $(lWyn) @lres 
GO


:connect DESKTOP-HN8MK56\SQL1

declare @lRes char(300) 
set @lRes = ''

set @lres = (select @@servername)
GO


--print @lRes1
--GO
*/