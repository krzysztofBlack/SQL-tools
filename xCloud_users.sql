USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [xlogin1]    Script Date: 2/13/2022 2:07:52 PM ******/
CREATE LOGIN [xcloud] WITH PASSWORD=N'Elamakota', DEFAULT_DATABASE=[tempdb], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [ksx]
GO
CREATE USER [xCloud_user] FOR LOGIN [xcloud] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [ksx]
GO
CREATE ROLE [xCloud_Role] AUTHORIZATION [dbo]
GO

USE [ksx]
GO
ALTER ROLE [xCloud_Role] ADD MEMBER [xCloud_user]
GO

select  TOP 100 * FROM ELA
select  TOP 100 * FROM local_vx_ela


CREATE VIEW [iods].[local_vx_ela]
AS
SELECT X.*
FROM            dbo.ela X
WHERE        (name = 'TOLA')
GO



CREATE VIEW [dbo].[local_vx_ela]
AS
SELECT X.*
FROM            dbo.ela X
WHERE        (name = 'TOLA')
GO

use [ksx]
GO
GRANT INSERT ON [dbo].[local_vx_ela] TO [xCloud_Role]
GO
use [ksx]
GO
GRANT SELECT ON [dbo].[local_vx_ela] TO [xCloud_Role]
GO

GRANT SELECT ON [iods].[local_vx_ela] TO [xCloud_Role]


EXECUTE AS LOGIN = 'xCloud';
SELECT permissions.permission_name
FROM fn_my_permissions(NULL, 'SERVER') AS
permissions

REVERT;


EXECUTE AS LOGIN = 'xCloud';
SELECT permissions.permission_name
FROM fn_my_permissions(NULL, 'Database') AS
permissions

SELECT * FROM fn_my_permissions('[dbo].[local_vx_ela]', 'OBJECT')   
    ORDER BY subentity_name, permission_name ;   

REVERT;

SELECT * FROM fn_my_permissions('xCloud_User', 'USER');  
GO  

use [ksx]
GO
GRANT EXECUTE ON [dbo].[local_sp_x_test] TO [xCloud_Role]
GO

GRANT EXECUTE ON [iods].[local_sp_x_test] TO [xCloud_Role]
GO


CREATE SCHEMA [iods]
GO



select sys.schemas.name 'Schema'
, sys.objects.name Object
, sys.database_principals.name username
, sys.database_permissions.type permissions_type
, sys.database_permissions.permission_name
, sys.database_permissions.state permission_state
, sys.database_permissions.state_desc
, state_desc + ' ' + permission_name + ' on ['+ sys.schemas.name + '].[' + sys.objects.name + '] to [' + sys.database_principals.name + ']' COLLATE LATIN1_General_CI_AS
from sys.database_permissions join sys.objects on sys.database_permissions.major_id = sys.objects.object_id 
join sys.schemas on sys.objects.schema_id = sys.schemas.schema_id
join sys.database_principals on sys.database_permissions.grantee_principal_id = sys.database_principals.principal_id
where sys.database_principals.name ='xcloud_Role'
order by 1, 2, 3, 5


select * from [iods].[local_vx_ela]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Krzysztof Szwarc
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION iods.local_ft_x_test(@xPar int ) 
RETURNS TABLE 
AS
RETURN 
(
	select  * from t1 where col1 <@xPar
)
GO

CREATE FUNCTION iods.local_ft_x_test2(@xPar int = 10, @xPar1 int = 15 ) 
RETURNS TABLE 
AS
RETURN 
(
	select  * from t1 where col1 >@xPar and col1<@xPar1
)
GO


CREATE FUNCTION iods.local_ft_x_test3() 
RETURNS TABLE 
AS
RETURN 
(
	select  * from t1 where col1 >1
)
GO


select top 100 * from [iods].[local_ft_x_test3]()
where col1 =10

select top 100 * from T1
where col1 =10

use ksx


select top 100 * from iods.local_ft_x_test2(DEFAULT,DEFAULt)




