USE [master]
GO
CREATE LOGIN [beksa] WITH PASSWORD=N'tola', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [ksx]
GO
CREATE USER [u_beksa] FOR LOGIN [beksa]
GO
USE [ksx]
GO
ALTER USER [u_beksa] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [ksx]
GO
ALTER ROLE [db_datareader] ADD MEMBER [u_beksa]
GO


