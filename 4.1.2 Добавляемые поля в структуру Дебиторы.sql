use [TRANSITTEST]
go

alter table Partners
add AsnNumberKM bit null

alter table Partners
add SSCCInnerCheck int null

alter table Partners
add KITUOpenCheck int null

alter table Partners
add KITUInnerCheck int null

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	ALTER PROC [dbo].[Add_Partner] @ExternalCode nvarchar(50), @Name nvarchar(250), @ShortName nvarchar(50), @RemainingShelfLife int = null,
				@PartnerGroupCode nvarchar(50) = null, @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) ='WMS', @autotest bit = 0,
				@AsnNumberKM bit = 0, @SSCCInnerCheck int = null, @KITUOpenCheck int = null, @KITUInnerCheck int = null
as
	BEGIN

		if @autotest = 1
			return
			
		if @PartnerGroupCode is not null and (select 1 where exists(select tid from PartnerGroups where ExternalCode = @PartnerGroupCode)) is null
			begin
				declare @TextErrorMsg nvarchar(max);
				set @TextErrorMsg = CONCAT('(51008) Не найдена группа партнера с кодом: #!', @PartnerGroupCode);
				THROW 51008, @TextErrorMsg, 16
			end;

		INSERT INTO Partners (ExternalCode, Name, ShortName, RemainingShelfLife, PartnerGroupCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate, AsnNumberKM, SSCCInnerCheck, KITUOpenCheck, KITUInnerCheck)
		VALUES (@ExternalCode, @Name, @ShortName, @RemainingShelfLife, @PartnerGroupCode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GetDate(), @AsnNumberKM, @SSCCInnerCheck, @KITUOpenCheck, @KITUInnerCheck)

	END;

