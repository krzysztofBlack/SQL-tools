USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [xlogin2]    Script Date: 3/19/2022 3:58:01 PM ******/
CREATE LOGIN [xlogin3] WITH PASSWORD=N'ala',
DEFAULT_DATABASE=[ksx], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [ksx]
GO
CREATE USER [xlogin3] FOR LOGIN [xlogin3] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE ROLE [role_x] AUTHORIZATION [dbo]
GO

ALTER ROLE [role_x] ADD MEMBER [xlogin3]
GO

REVOKE SELECT ON [dbo].[ela] TO [role_x] AS [dbo]
REVOKE EXECUTE ON [dbo].[lsp_1] TO [role_x] AS [dbo]
REVOKE SELECT ON [dbo].[ela2] TO [role_x] AS [dbo]

grant SELECT ON [dbo].[ela] TO [role_x] AS [dbo]
grant EXECUTE ON [dbo].[lsp_1] TO [role_x] AS [dbo]
grant SELECT ON [dbo].[ela2] TO [role_x] AS [dbo]

DENY SELECT ON [dbo].[ela2] TO [role_x]

ALTER ROLE [db_datareader] ADD MEMBER [role_x]
GO

CREATE VIEW [dbo].[local_vx_ela2]
AS
SELECT *
FROM            dbo.ela2
--WHERE        (name = 'TOLA')
GO



