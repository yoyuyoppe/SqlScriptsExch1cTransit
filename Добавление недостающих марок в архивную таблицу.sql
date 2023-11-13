use TRANSIT

go

declare @ExternalCode nvarchar(50) = 'bd4bf5fc-60eb-11ee-98f8-e43d1a0d77d1' -- guid заказа поставщика
declare @DOCNUM nvarchar(50) = newID()
declare @DOC_SENDER nvarchar (10) = '1С'
declare @DOC_RECEIVER nvarchar (10) = 'WMS'

insert into tbl_ArchiveKM (ExternalCode, MaterialCode, KI, KIGU, KITU, SSCC, StatusKI, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
select NEWID() as ExternalCode, *
from
(select distinct dr.MaterialCode, drm1C.KI, drm1C.KIGU, drm1C.KITU, drm1C.SSCC, 'Accepted' as StatusKI, 
@DOCNUM as DOCNUM, @DOC_SENDER AS DOC_DENDER, @DOC_RECEIVER AS DOC_RECEIVER, GETDATE() as RecorDate 
from tbl_DeliveryRequestMarks as drm1C
left join tbl_DeliveryResponseMarks as drmWMS
on drm1C.KI = drmWMS.KI
left join tbl_DeliveryRequest as dr
on drm1C.DeliveryRequestCode = dr.DeliveryRequestCode
and drm1c.DeliveryRequestRowCode = dr.ExternalCode
where drm1C.DeliveryRequestCode = @ExternalCode and drmWMS.KI is null) as finish_q

exec Add_DocNum @DocNum = @DOCNUM

print(CONCAT('DOCNUM: ', @DOCNUM))







