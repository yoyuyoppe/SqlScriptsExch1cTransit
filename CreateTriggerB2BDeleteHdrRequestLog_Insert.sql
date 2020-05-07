use LEADWMS
go

if OBJECT_ID('B2BDeleteHdrRequestLog_Insert', 'TR') is not null
	drop trigger B2BDeleteHdrRequestLog_Insert

GO

create trigger B2BDeleteHdrRequestLog_Insert
on LEADWMS.dbo.wwwB2BDeleteHdrRequestLog
after Insert
as

begin try

	insert into TRANSIT.dbo.B2BDeleteHdrRequestLog (tid, Transaction_id, ExternalCode, id_user, Username, RecordDate, DeliveryType)
	select 
		b2blog.tid, b2blog.Transaction_id, ElementIntegration_623.TargetValue, b2blog.user_id, p.ShortName, b2blog.recorddate, t.ExternalCode as DeliveryType
	from 
		inserted as b2blog with (nolock)

		left join LEADWMS.dbo.temp_ElementIntegration_623 as ElementIntegration_623 with (nolock)
		on b2blog.Transaction_id = ElementIntegration_623.LocalValue

		left join LEADWMS.dbo.Users as u with (nolock)
		on b2blog.user_id = u.tid

		left join LEADWMS.dbo.People as p with (nolock)
		on u.People_id = p.tid

		left join LEADWMS.dbo.hdr_DeliveryRequest as h
		on b2blog.Transaction_id = h.Transaction_id

		left join LEADWMS.dbo.DeliveryTypes as t
		on h.DeliveryType_id = t.tid

end try

begin catch
--
end catch;

