if OBJECT_ID('Add_ArchiveKM', 'P') is not null
drop procedure Add_ArchiveKM

go

CREATE PROC Add_ArchiveKM
	@ExternalCode nvarchar(200),
	@MaterialCode nvarchar(200),
	@KI nvarchar(200),
	@KIGU nvarchar(200) = null,
	@KITU nvarchar(200) = null,
	@SSCC nvarchar(200) = null,
	@StatusKI nvarchar(200),
	@DOC_SENDER nvarchar(25) = '1Ñ',
	@DOC_RECEIVER nvarchar(25) = 'WMS',
	@autotest bit = 0,
	@DOCNUM nvarchar(200)
AS
begin
	
		if @autotest = 1
			return
		
		INSERT INTO tbl_ArchiveKM (ExternalCode, MaterialCode, KI, KIGU, KITU, SSCC, StatusKI, DOC_SENDER, DOC_RECEIVER, RecordDate, DOCNUM)
		VALUES(@ExternalCode, @MaterialCode, @KI, @KIGU, @KITU, @SSCC, @StatusKI, @DOC_SENDER, @DOC_RECEIVER, GetDate(), @DOCNUM)
	
end
