if OBJECT_ID('Add_StatusKMEGAIS', 'P') is not null
drop procedure Add_StatusKMEGAIS

go

CREATE PROC Add_StatusKMEGAIS
	@ExternalCode nvarchar(200),
	@DeliveryRequestCode nvarchar(200),
	@DeliveryRequestRowCode nvarchar(200),
	@KI nvarchar(200),
	@KIGU nvarchar(200) = null,
	@KITU nvarchar(200) = null,
	@SSCC nvarchar(200) = null,
	@StatusKI nvarchar(200) = 'ShipmentIsAllowed',
	@DOC_SENDER nvarchar(25) = '1С',
	@DOC_RECEIVER nvarchar(25) = 'WMS',
	@autotest bit = 0,
	@DOCNUM nvarchar(200)
AS
begin
	
		if @autotest = 1
			return
		
		INSERT INTO tbl_StatusKMEGAIS (ExternalCode, DeliveryRequestCode, DeliveryRequestRowCode, KI, KIGU, KITU, SSCC, StatusKI, DOC_SENDER, DOC_RECEIVER, RecordDate, DOCNUM)
		VALUES(@ExternalCode, @DeliveryRequestCode, @DeliveryRequestRowCode, @KI, @KIGU, @KITU, @SSCC, @StatusKI, @DOC_SENDER, @DOC_RECEIVER, GetDate(), @DOCNUM)
	
end
