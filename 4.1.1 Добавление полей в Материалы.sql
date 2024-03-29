USE [TRANSITTEST]
go

alter table Materials
add IsNeedMarks bit NULL;

alter table Materials
add EGAIS bit NULL;

GO
/****** Object:  StoredProcedure [dbo].[Add_Material]    Script Date: 07.04.2023 17:27:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[Add_Material] 
	@ExternalCode nvarchar(50), @Article nvarchar(50) = null, @Name nvarchar(500), @Shelflife int = null, @BaseUnitCode nvarchar(50),
	@CargoUnitCode nvarchar(50) = null, @MaterialGroupCode nvarchar(50) = null, @StorageGroupCode nvarchar(50) = null, @PickingGroupCode nvarchar(50) = null,
	@IsNeedBatch bit = null, @IsProductionDateCheck bit = null, @IsNeedAm bit = null, @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', 
	@DOC_RECEIVER nvarchar(50) = 'WMS', @shortname nvarchar(255), @ReplenishmentGroupCode nvarchar(50) = null, @autotest bit = 0, @IsNeedMarks bit =0, @EGAIS bit =0
AS 
BEGIN
	
	if @autotest = 1
		return

		IF @IsNeedMarks = 1 and @EGAIS = 1
				begin
					declare @TextErrorMsg nvarchar(max)				
					set @TextErrorMsg = '(51011) Для материала может быть передан только один из признаков (учет маркировочной продукции или учет в системе Егаис)';
					THROW 51011, @TextErrorMsg, 16
				end;

	if (select LocalValue from LEADWMS.dbo.temp_ElementIntegration_65 where TargetValue = @ExternalCode) is not null
		and (select 1 where EXISTS (select tid from LEADWMS.dbo.Materials where tid = (select LocalValue from LEADWMS.dbo.temp_ElementIntegration_65 where TargetValue = @ExternalCode))) is null
		delete from LEADWMS.dbo.temp_ElementIntegration_65 where TargetValue = @ExternalCode

	INSERT INTO Materials(ExternalCode, Article, Name, ShelfLife, BaseUnitCode, CargoUnitCode, MaterialGroupCode, StorageGroupCode, PickingGroupCode, IsNeedBatch, IsProductionDateCheck, IsNeedAM, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate, ShortName, ReplenishmentGroupCode, IsNeedMarks, EGAIS)
	VALUES(@ExternalCode, @Article, @Name, @ShelfLife, @BaseUnitCode, @CargoUnitCode, @MaterialGroupCode, @StorageGroupCode, @PickingGroupCode, @IsNeedBatch, @IsProductionDateCheck, @IsNeedAM, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE(), @shortname, @ReplenishmentGroupCode, @IsNeedMarks, @EGAIS)

END;

