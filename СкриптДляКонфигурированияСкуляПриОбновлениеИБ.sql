USE master;
GO

EXECUTE sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

exec sp_configure 'max degree of parallelism', 10;
GO

exec sp_configure 'cost threshold for parallelism', 10;
GO

RECONFIGURE WITH OVERRIDE;
GO

EXECUTE sp_configure 'show advanced options', 0;
GO

RECONFIGURE;
GO


