USE TRANSIT

GO

-- "*" - звездочкой отмечены параметры, которые можно менять
declare @ExternalCode nvarchar(250) = '' -- * guid заказа поставщику 
declare @DOCNUM nvarchar(50) = NEWID() -- произвольный идентификатор пакета. Сгенерируется автоматически
declare @StatusKI nvarchar(200) = 'Accepted' -- Индикаторы: Accepted – Принят, Shipped – Отгружен
declare @Sender nvarchar(200) = '1С' -- Отправитель
declare @Receiver nvarchar(200) = 'WMS' -- Получатель

if @ExternalCode = ''
	THROW 51000, 'Не заполнен обязательный параметр @ExternaCode', 16

-- добавляет в tbl_ArchiveKM марки, у которых статус в таблице tbl_DeliveryRequestMarks = ER
insert into tbl_ArchiveKM (ExternalCode, MaterialCode, KI, KIGU, KITU, SSCC, StatusKI, RecordDate, DOCNUM, DOC_SENDER, DOC_RECEIVER)
select tdrm.KI as ExternalCode, tdr.MaterialCode, tdrm.KI, tdrm.KIGU, tdrm.KITU, tdrm.SSCC, @StatusKI as StatusKI,
GetDate() as RecordDate, @DOCNUM as DOCNUM, @Sender as DOC_SENDER, @Receiver as DOC_RECEIVER 
from tbl_DeliveryRequestMarks tdrm 
left join tbl_DeliveryRequest as tdr
on tdrm.DeliveryRequestRowCode = tdr.ExternalCode
where tdrm.DeliveryRequestCode = @ExternalCode and tdrm.PROCESSED_STATUS = 'ER'

-- добавляет идентификатор пакета @DOCNUM в таблицу DOCNUM
exec Add_DocNum @DOCNUM = @DOCNUM
print(CONCAT('DOCNUM: ', @DOCNUM))