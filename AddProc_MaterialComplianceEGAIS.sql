USE TRANSIT
GO

if OBJECT_ID('Add_MaterialComplianceEGAIS', 'P') is not null
	drop procedure Add_MaterialComplianceEGAIS

GO

CREATE PROC Add_MaterialComplianceEGAIS
	@ExternalCode nvarchar(50),
	@MaterialCode nvarchar(50),
	@AlcoCode nvarchar(50),
	@DOC_SENDER nvarchar(50) = '1С',
	@DOC_RECEIVER nvarchar(50) = 'WMS',
	@DOCNUM nvarchar(50)
AS
	BEGIN
		
			IF (select 1 where EXISTS (select ExternalCode from Materials where ExternalCode = @MaterialCode)) is null
				begin
					declare @TextErrorMsg nvarchar(max)				
					set @TextErrorMsg = CONCAT('(51003) Не найден материал с кодом: #!', @MaterialCode);
					THROW 51000, @TextErrorMsg, 16
				end;

			declare @RecordDate datetime = GetDate();

			insert into MaterialComplianceEGAIS (ExternalCode, MaterialCode, AlcoCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
			Values (@ExternalCode, @MaterialCode, @AlcoCode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, @RecordDate)

	END
