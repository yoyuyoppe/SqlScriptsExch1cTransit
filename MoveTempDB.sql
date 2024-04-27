use master
alter database tempdb
modify file (
name = tempdev,
filename = N'C:\TempDB\tempdb.mdf'
)
go

alter database tempdb
modify file (
name = templog,
filename = N'C:\TempDB\tempdb.ldf'
)