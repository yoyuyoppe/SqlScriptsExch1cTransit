USE TRANSIT

if OBJECT_ID('Add_hdrDeliveryRequest', 'P') is not null
	drop procedure Add_hdrDeliveryRequest
if OBJECT_ID('Add_tblDeliveryRequest', 'P') is not null
	drop procedure Add_tblDeliveryRequest
if OBJECT_ID('UpdateQuantityToZero', 'P') is not null
	drop procedure UpdateQuantityToZero
if OBJECT_ID('Add_DocNum', 'P') is not null
	drop procedure Add_DocNum
if OBJECT_ID('GetDocnum', 'P') is not null
	drop procedure GetDocnum
if OBJECT_ID('GetDeliveryResponce', 'P') is not null
	drop procedure GetDeliveryResponce
if OBJECT_ID('DocNumIsDone', 'P') is not null
	drop procedure DocNumIsDone
if OBJECT_ID('Add_Material', 'P') is not null
	drop procedure Add_Material
if OBJECT_ID('Add_Units', 'P') is not null
	drop procedure Add_Units
if OBJECT_ID('Add_MaterialGroup', 'P') is not null
	drop procedure Add_MaterialGroup
if OBJECT_ID('Add_StorageGroup', 'P') is not null
	drop procedure Add_StorageGroup	
if OBJECT_ID('Add_PickingGroup', 'P') is not null
	drop procedure Add_PickingGroup	
if OBJECT_ID('Add_FormFactor', 'P') is not null
	drop procedure Add_FormFactor
if OBJECT_ID('Add_MaterialUnit', 'P') is not null
	drop procedure Add_MaterialUnit
if OBJECT_ID('Add_MaterialUnitBarcode', 'P') is not null
	drop procedure Add_MaterialUnitBarcode
if OBJECT_ID('Add_Producer', 'P') is not null
	drop procedure Add_Producer
if OBJECT_ID('Add_MaterialAndProducer', 'P') is not null
	drop procedure Add_MaterialAndProducer
if OBJECT_ID('Add_hdrTransport', 'P') is not null
	drop procedure Add_hdrTransport
if OBJECT_ID('Add_tblTransport', 'P') is not null
	drop procedure Add_tblTransport
if OBJECT_ID('Add_PartnerGroup', 'P') is not null
	drop procedure Add_PartnerGroup
if OBJECT_ID('Add_Partner', 'P') is not null
	drop procedure Add_Partner
if OBJECT_ID('GetDeliveryStatusForRouteDocuments', 'P') is not null
	drop procedure GetDeliveryStatusForRouteDocuments
if OBJECT_ID('repWarehouseSummary', 'P') is not null
	DROP PROCEDURE repWarehouseSummary
if OBJECT_ID('Add_BatchNumbers', 'P') is not null
	DROP PROCEDURE Add_BatchNumbers
if OBJECT_ID('Get_B2BDeleteHdrRequest', 'P') is not null
	DROP PROCEDURE Get_B2BDeleteHdrRequest
if OBJECT_ID('Patch_B2BDeleteHdrRequest', 'P') is not null
	DROP PROCEDURE Patch_B2BDeleteHdrRequest

GO
	CREATE PROC Add_hdrDeliveryRequest
		@ExternalCode nvarchar(50),
		@DeliveryNumber nvarchar(50)=null,
		@DeliveryBarcode nvarchar(50)=null,
		@DeliveryTypeCode nvarchar(50),
		@OwnerCode nvarchar(50),
		@PartnerCode nvarchar(50)=null,
		@DeliveryDate datetime=null,
		@DeliveryTime nchar(5)=null,
		@DestinationAddress nvarchar(500)=null,
		@DeliveryArea nvarchar(500)=null,
		@Department nvarchar(500)=null,
		@Comment nvarchar(200)=null, 
		@DocNum nvarchar(50),
		@DocSender nvarchar(50) = '1С',
		@DocReceiver nvarchar(50) = 'WMS',
		@RecordDate datetime = null,
		@autotest bit = 0
	AS
	Begin
		
		if @autotest = 1
			return
		
		declare @TextErrorMsg nvarchar(max)			
			
		IF @PartnerCode is not null and (select 1 where EXISTS (select ExternalCode from Partners where ExternalCode = @PartnerCode)) is null
				begin					
					set @TextErrorMsg = CONCAT('Не найден партнер (контрагент) с кодом: ', @PartnerCode);
					THROW 51000, @TextErrorMsg, 16
				end;
		
		IF (select 1 where EXISTS (select ExternalCode from Partners where ExternalCode = @OwnerCode)) is null
				begin
					set @TextErrorMsg = CONCAT('Не найден владелец запасов (кластер) с кодом: ', @OwnerCode);
					THROW 51000, @TextErrorMsg, 16
				end;

		IF (select 1 where exists (select tid from LEADWMS.dbo.wwwB2BDeleteHdrRequestLog where Transaction_id = 
			(select LocalValue from LEADWMS.dbo.temp_ElementIntegration_623 where TargetValue = @ExternalCode))) = 1
			begin
				delete from LEADWMS.dbo.temp_ElementIntegration_623 where TargetValue = @ExternalCode
				delete from LEADWMS.dbo.temp_ElementIntegration_625 where TargetValue IN (select ExternalCode 
							from tbl_DeliveryRequest 
							where DeliveryRequestCode = @ExternalCode
							group by ExternalCode
							)
			end;
			
		set @RecordDate = GetDate();
	
		insert into hdr_DeliveryRequest(ExternalCode, DeliveryNumber, DeliveryBarcode, DeliveryTypeCode, OwnerCode, PartnerCode, DeliveryDate, DeliveryTime, DestinationAddress, DeliveryArea, Comment, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate, Department)
				values (@ExternalCode, @DeliveryNumber, @DeliveryBarcode, @DeliveryTypeCode, @OwnerCode, @PartnerCode, @DeliveryDate, @DeliveryTime, @DestinationAddress, @DeliveryArea, @Comment, @DocNum, @DocSender, @DocReceiver, @RecordDate, @Department);

		return

	End
GO
	CREATE PROC Add_tblDeliveryRequest
		@ExternalCode nvarchar(50),
		@DeliveryRequestCode nvarchar(50),
		@MaterialCode nvarchar(50),
		@Quantity decimal(25,6),
		@MaterialUnitCode nvarchar(50),
		@MaterialBatch nvarchar(50) = null,
		@MaterialSeriesCode nvarchar(50) = null,
		@QualityTypeCode nvarchar(50) = null,
		@DocNum nvarchar(50),
		@DocSender nvarchar(50) = '1С',
		@DocReceiver nvarchar(50) = 'WMS',
		@RecordDate datetime = null,
		@autotest bit = 0
	as
		begin
			
			if @autotest = 1
				return

			IF (select 1 where EXISTS (select ExternalCode from Materials where ExternalCode = @MaterialCode)) is null
				begin
					declare @TextErrorMsg nvarchar(max)				
					set @TextErrorMsg = CONCAT('Не найден материал с кодом: ', @MaterialCode);
					THROW 51000, @TextErrorMsg, 16
				end;

			set @RecordDate = GetDate();
	
			insert into tbl_DeliveryRequest(ExternalCode, DeliveryRequestCode, MaterialCode, Quantity, MaterialUnitCode, MaterialBatch, MaterialSeriesCode, QualityTypeCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
			values(@ExternalCode, @DeliveryRequestCode, @MaterialCode, @Quantity, @MaterialUnitCode, @MaterialBatch, @MaterialSeriesCode, @QualityTypeCode, @DocNum, @DocSender, @DocReceiver, @RecordDate)

			return
		end 

GO
	CREATE PROC UpdateQuantityToZero
	@DeliveryRequestCode nvarchar(50),
	@DocNum nvarchar(50)
	as 
begin
	
	declare @RecordDate datetime;
	set @RecordDate = GetDate();

	insert into TRANSIT.dbo.tbl_DeliveryRequest(ExternalCode, DeliveryRequestCode, MaterialCode, Quantity, MaterialUnitCode, MaterialBatch, MaterialSeriesCode, 
				QualityTypeCode, SpecificationCode, PROCESSED_DATE, PROCESSED_STATUS, PROCESSED_COMMENT, DOCNUM, DOC_SENDER, DOC_RECEIVER, CHECKED_BY_PI, RecordDate)
	select DISTINCT ExternalCode, @DeliveryRequestCode, MaterialCode, 0, MaterialUnitCode, MaterialBatch, MaterialSeriesCode, 
				QualityTypeCode, SpecificationCode, null, null, null, @DocNum, DOC_SENDER, DOC_RECEIVER, null, @RecordDate
	from tbl_DeliveryRequest
					where 
					ExternalCode not in (
											select ExternalCode
											from tbl_DeliveryRequest
											where DeliveryRequestCode = @DeliveryRequestCode
											and DOCNUM = @DocNum
											and Quantity > 0
										)
						and 
						exists (
											select ExternalCode
											from tbl_DeliveryRequest
											where DeliveryRequestCode = @DeliveryRequestCode
											and DOCNUM = @DocNum
											and Quantity > 0)
						and DeliveryRequestCode = @DeliveryRequestCode
	return
end;

GO

CREATE PROC

	Add_DocNum @DocNum nvarchar(50), @DocSender nvarchar(50) = '1С', @DocReceiver nvarchar(50) = 'WMS', @autotest bit = 0
 as 

 begin
	
	if @autotest = 1
		return
		
	declare @RecordDate datetime;
	set @RecordDate = GETDATE();

	insert into DOCNUM (DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES (@DocNum, @DocSender, @DocReceiver, @RecordDate)

return

end;

GO

CREATE PROC

	GetDocnum @filter nvarchar(max)
as

begin
	
	declare @query nvarchar(max) = '
	select 
		CASE
			WHEN hdr_dr.tid is null THEN 0
			ELSE 1
		END AS type_response,
	docnum.docnum, docnum.PROCESSED_DATE as proc_date, docnum.PROCESSED_STATUS as proc_status, CAST(docnum.PROCESSED_COMMENT AS nvarchar(100)) as comment, docnum.CHECKED_BY_PI as proc_date_beg, docnum.RecordDate
	from [TRANSIT].[dbo].[DOCNUM] as docnum
	left join [TRANSIT].[dbo].[hdr_DeliveryResponse] as hdr_dr
	on docnum.DOCNUM = hdr_dr.DOCNUM
	where &filter
	'; 

	set @query = REPLACE(@query, '&filter', @filter)
			
	exec (@query);

end;

GO

CREATE PROC

	GetDeliveryResponce @DocNum nvarchar(50)

as

begin
		
select 
    hdr_dr.ExternalCode as DeliveryRequestCode, 
    hdr_dr.DeliveryTypeCode,
    null as ExternalCode, 
    null as MaterialCode,
    null as Quantity,
    null as MaterialSeriesCode,
	null as MaterialUnitCode,
	null as MaterialBatch,
	null as SpecificationCode,
	null as QualityTypeCode,
	null as ProductionDate,
	null as ExpirationDate,
    hdr_dr.DeliveryStatus as Status,
    hdr_dr.PROCESSED_COMMENT as Comment,
	hdr_dr.PaletNumbers,
	hdr_dr.DOCNUM
from 
    hdr_DeliveryResponse as hdr_dr
where 
    hdr_dr.DOCNUM = @DocNum and hdr_dr.CHECKED_BY_PI is null
group by
    hdr_dr.ExternalCode, 
    hdr_dr.DeliveryTypeCode,
    hdr_dr.DeliveryStatus, 
    hdr_dr.PROCESSED_COMMENT,
	hdr_dr.PaletNumbers,
	hdr_dr.DOCNUM

union

select 
    tbl_dr.DeliveryRequestCode, 
    null,
    tbl_dr.ExternalCode, 
    tbl_dr.MaterialCode,
    tbl_dr.Quantity,
    tbl_dr.MaterialSeriesCode,
	tbl_dr.MaterialUnitCode,
	tbl_dr.MaterialBatch,
	tbl_dr.SpecificationCode,
	tbl_dr.QualityTypeCode,
	tbl_dr.ProductionDate,
	tbl_dr.ExpirationDate,
    tbl_dr.PROCESSED_STATUS as Status,
    tbl_dr.PROCESSED_COMMENT as Comment,
	null,
	tbl_dr.DOCNUM
FROM
    tbl_DeliveryResponse as tbl_dr 
where 
	tbl_dr.DOCNUM = @DocNum and tbl_dr.CHECKED_BY_PI is null
group BY   
    tbl_dr.DeliveryRequestCode, 
    tbl_dr.ExternalCode, 
    tbl_dr.MaterialCode,
    tbl_dr.Quantity,
    tbl_dr.MaterialSeriesCode,
	tbl_dr.MaterialUnitCode,
	tbl_dr.MaterialBatch,
	tbl_dr.SpecificationCode,
	tbl_dr.QualityTypeCode,
	tbl_dr.ProductionDate,
	tbl_dr.ExpirationDate,
    tbl_dr.PROCESSED_STATUS,
    tbl_dr.PROCESSED_COMMENT,
	tbl_dr.DOCNUM

order by
	DeliveryRequestCode, ExternalCode

end;

go

CREATE PROC DocNumIsDone @DocNum nvarchar(50), @checked_by datetime, @proc_date datetime, @autotest bit = 0
as
begin

	begin tran @DocNum 
		with mark N'Update CHECKED_BY_PI, PROCESSED_STATUS, RecordDate in tables (DOCNUM, hdr_DeliveryResponce, tbl_DeliveryResponce)';
		
	begin try		
		
		declare @RecDate datetime = GetDate();
			
		update DOCNUM 
		set CHECKED_BY_PI = @checked_by, PROCESSED_STATUS ='OK', PROCESSED_DATE = @proc_date, RecordDate = @RecDate
		where DOCNUM = @DocNum

		update hdr_DeliveryResponse
		set CHECKED_BY_PI = @checked_by, PROCESSED_STATUS ='OK', PROCESSED_DATE = @proc_date, RecordDate = @RecDate
		where DOCNUM = @DocNum

		update tbl_DeliveryResponse
		set CHECKED_BY_PI = @checked_by, PROCESSED_STATUS ='OK', PROCESSED_DATE = @proc_date, RecordDate = @RecDate
		where DOCNUM = @DocNum

		update StockCorrection 
		set CHECKED_BY_PI = @checked_by, PROCESSED_STATUS ='OK', PROCESSED_DATE = @proc_date, RecordDate = @RecDate
		where DOCNUM = @DocNum

	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback tran @DocNum;
		throw;
	end catch;

	if @@TRANCOUNT > 0 and @autotest = 0
		commit tran @DocNum;
	else if @@TRANCOUNT > 0 and @autotest = 1
		rollback tran @DocNum;

end;

GO

CREATE PROC Add_Material 
	@ExternalCode nvarchar(50), @Article nvarchar(50) = null, @Name nvarchar(500), @Shelflife int = null, @BaseUnitCode nvarchar(50),
	@CargoUnitCode nvarchar(50) = null, @MaterialGroupCode nvarchar(50) = null, @StorageGroupCode nvarchar(50) = null, @PickingGroupCode nvarchar(50) = null,
	@IsNeedBatch bit = null, @IsProductionDateCheck bit = null, @IsNeedAm bit = null, @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', 
	@DOC_RECEIVER nvarchar(50) = 'WMS', @shortname nvarchar(255), @autotest bit = 0
AS 
BEGIN
	
	if @autotest = 1
		return

	INSERT INTO Materials(ExternalCode, Article, Name, ShelfLife, BaseUnitCode, CargoUnitCode, MaterialGroupCode, StorageGroupCode, PickingGroupCode, IsNeedBatch, IsProductionDateCheck, IsNeedAM, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate, ShortName)
	VALUES(@ExternalCode, @Article, @Name, @ShelfLife, @BaseUnitCode, @CargoUnitCode, @MaterialGroupCode, @StorageGroupCode, @PickingGroupCode, @IsNeedBatch, @IsProductionDateCheck, @IsNeedAM, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE(), @shortname)

END;

GO

CREATE PROC Add_Units @ExternalCode nvarchar(50), @Name nvarchar(200), @ShortName nvarchar(50), 
					@DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN
	
	if @autotest = 1
		return
	
	INSERT INTO Units (ExternalCode, Name, ShortName, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES (@ExternalCode, @Name, @ShortName, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_MaterialGroup @ExternalCode nvarchar(50), @Name nvarchar(250), @DOCNUM nvarchar(50),
							@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN

if @autotest = 1
	return

	INSERT INTO MaterialGroups(ExternalCode, Name, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES(@ExternalCode, @Name, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_StorageGroup @ExternalCode nvarchar(50), @Name nvarchar(250), @DOCNUM nvarchar(50),
							@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN

if @autotest = 1
	return

	INSERT INTO StorageGroup(ExternalCode, Name, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES(@ExternalCode, @Name, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_PickingGroup @ExternalCode nvarchar(50), @Name nvarchar(250), @DOCNUM nvarchar(50),
							@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN

if @autotest = 1
	return

	INSERT INTO PickingGroups(ExternalCode, Name, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES(@ExternalCode, @Name, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_FormFactor @ExternalCode nvarchar(50), @Name nvarchar(250), @PickingPriority int, @DOCNUM nvarchar(50),
							@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN

if @autotest = 1
	return

	INSERT INTO FormFactors(ExternalCode, Name, PickingPriority, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES(@ExternalCode, @Name, @DOCNUM, @PickingPriority, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_MaterialUnit
@ExternalCode nvarchar(50), @MaterialCode nvarchar(50), @UnitCode nvarchar(50), @Koeff decimal(25,6), @Weight decimal(25,6) = null, @Volume decimal(25,5)=null,
@PackTypeCode nvarchar(50)=null, @FormFactorCode nvarchar(50) = null, @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
as 
BEGIN

if @autotest = 1
	return

declare @TextErrorMsg nvarchar(max)					

if (select 1 where exists(select tid from Materials where ExternalCode = @MaterialCode)) is null
	begin
		set @TextErrorMsg = CONCAT('Не найден владелец единицы измерения в таблице "Materials" с кодом: ', @MaterialCode);
		THROW 51000, @TextErrorMsg, 16
	end;
else if (select 1 where exists (select tid from Units where ExternalCode = @UnitCode)) is null
	begin
		set @TextErrorMsg = CONCAT('Не найдена единица по классификатору в таблице "Units" с кодом: ', @UnitCode);
		THROW 51000, @TextErrorMsg, 16
	end;
	
INSERT INTO MaterialUnits(ExternalCode, MaterialCode, UnitCode, Koeff, Weight, Volume, PackTypeCode, FormFactorCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)		
VALUES (@ExternalCode, @MaterialCode, @UnitCode, @Koeff, @Weight, @Volume, @PackTypeCode, @FormFactorCode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_MaterialUnitBarcode
	@ExternalCode nvarchar(50), @MaterialCode nvarchar(50), @MaterialUnitCode nvarchar(50), @Barcode nvarchar(50), 
	@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @DOCNUM nvarchar(50), @autotest bit = 0
AS
BEGIN
	
	if @autotest = 1
		return
	
	declare @TextErrorMsg nvarchar(max)
	if (select 1 where exists(select tid from Materials where ExternalCode = @MaterialCode)) is null
		begin
			set @TextErrorMsg = CONCAT('Не найден материал с кодом: ', @MaterialCode);
			THROW 51000, @TextErrorMsg, 16
		end;

	if (select 1 where exists(select tid from MaterialUnits where ExternalCode = @MaterialUnitCode)) is null
		begin
			set @TextErrorMsg = CONCAT('Не найдена единица материала с кодом: ', @MaterialUnitCode);
			THROW 51000, @TextErrorMsg, 16
		end;

	INSERT INTO MaterialUnitBarcodes (ExternalCode, MaterialCode, MaterialUnitCode, Barcode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES (@ExternalCode, @MaterialCode, @MaterialUnitCode, @Barcode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Add_Producer @ExternalCode nvarchar(50), @Name nvarchar(250), @ShortName nvarchar(50)=null, @DOCNUM nvarchar(50),
			@DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN
	
	if @autotest = 1
		return

	INSERT INTO Producers(ExternalCode, Name, ShortName, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
	VALUES(@ExternalCode, @Name, @ShortName, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO 

CREATE PROC Add_MaterialAndProducer @ExternalCode nvarchar(50), @ProducerCode nvarchar(50), @MaterialCode nvarchar(50), @DOCNUM nvarchar(50), 
				@DOC_SENDER nvarchar(50) = '1C', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit = 0
AS
BEGIN

	if @autotest = 1
		return
	
	declare @TextErrorMsg nvarchar(max)
	if (select 1 where exists(select tid from Producers where ExternalCode = @ProducerCode)) is null
		begin
			set @TextErrorMsg = CONCAT('Не найден производитель с кодом: ', @ProducerCode);
			THROW 51000, @TextErrorMsg, 16
		end;

	if (select 1 where exists(select tid from Materials where ExternalCode = @MaterialCode)) is null
		begin
			set @TextErrorMsg = CONCAT('Не найден материал с кодом: ', @MaterialCode);
			THROW 51000, @TextErrorMsg, 16
		end;

	INSERT INTO MaterialsAndProducers(ExternalCode, ProducerCode, MaterialCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)	
	VALUES(@ExternalCode, @ProducerCode, @MaterialCode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO 

CREATE PROC Add_hdrTransport 
	@ExternalCode nvarchar (50), @TransportBrand nvarchar(50), @TransportNumber nvarchar(50), 
	@DriverFirstName nvarchar(50)=null, @DriverLastName nvarchar(50)=null, @DriverMiddleName nvarchar(50)=null,
	@HandlingTypeCode nvarchar(50), @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50)='1С', @DOC_RECEIVER nvarchar(50)='WMS',
	@DeliveryDate datetime=null, @DeliveryTime varchar(20)=null, @RouteNumber varchar(500)=null, @MaxPalletCount int, @MaxPalletHeight decimal(25,6), 
	@RecordDate datetime = null, @autotest bit=0
AS
	BEGIN
		
		if @autotest = 1
			return

		/*if (select 1 where exists(select tid from hdr_Transport where ExternalCode = @ExternalCode and RouteNumber = @RouteNumber)) is not null
			return*/

		INSERT INTO hdr_Transport (ExternalCode, TransportBrand, TransportNumber, DriverFirstName, DriverLastName, DriverMiddleName, HandlingTypeCode, DOCNUM, DOC_SENDER,
			DOC_RECEIVER, DeliveryDate, DeliveryTime, RouteNumber, MaxPalletCount, MaxPalletHeight, RecordDate)
		VALUES (@ExternalCode, @TransportBrand, @TransportNumber, @DriverFirstName, @DriverLastName, @DriverMiddleName, @HandlingTypeCode, @DOCNUM, @DOC_SENDER,
			@DOC_RECEIVER, @DeliveryDate, @DeliveryTime, @RouteNumber, @MaxPalletCount, @MaxPalletHeight, GETDATE())

	END;

GO

CREATE PROC Add_tblTransport
	@ExternalCode nvarchar(50), @TransportCode nvarchar(50), @DeliveryRequestCode nvarchar(50), @Priority int=null,
	@DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50)='1С', @DOC_RECEIVER nvarchar(50)='WMS', @autotest bit=0
AS
	BEGIN
		
		if @autotest = 1
			return

		if (select 1 where exists(select tid from hdr_Transport where ExternalCode = @TransportCode)) is null
			begin
				declare @TextErrorMsg nvarchar(max);
				set @TextErrorMsg = CONCAT('Не найден транспорт с кодом:', @TransportCode);
				THROW 51, @TextErrorMsg, 16
			end;

		INSERT INTO tbl_Transport (ExternalCode, TransportCode, DeliveryRequestCode, Priority, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
		VALUES(@ExternalCode, @TransportCode, @DeliveryRequestCode, @Priority, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

	END;

	GO

	CREATE PROC Add_PartnerGroup @ExternalCode nvarchar(50), @Name nvarchar(250), @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) ='1С', @DOC_RECEIVER nvarchar(50) ='WMS', @autotest bit = 0
	AS
	BEGIN
		
		if @autotest = 1
			return

		INSERT INTO PartnerGroups (ExternalCode, Name, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
		VALUES (@ExternalCode, @Name, @DOCNUM, @DOC_SENDER,@DOC_RECEIVER, GetDate())

	END;

	GO

	CREATE PROC Add_Partner @ExternalCode nvarchar(50), @Name nvarchar(250), @ShortName nvarchar(50), @RemainingShelfLife int = null,
				@PartnerGroupCode nvarchar(50) = null, @DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) ='WMS', @autotest bit = 0
as
	BEGIN

		if @autotest = 1
			return
			
		if @PartnerGroupCode is not null and (select 1 where exists(select tid from PartnerGroups where ExternalCode = @PartnerGroupCode)) is null
			begin
				declare @TextErrorMsg nvarchar(max);
				set @TextErrorMsg = CONCAT('Не найдена группа партнера с кодом:', @PartnerGroupCode);
				THROW 51, @TextErrorMsg, 16
			end;

		INSERT INTO Partners (ExternalCode, Name, ShortName, RemainingShelfLife, PartnerGroupCode, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
		VALUES (@ExternalCode, @Name, @ShortName, @RemainingShelfLife, @PartnerGroupCode, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GetDate())

	END;

GO

CREATE PROC GetDeliveryStatusForRouteDocuments @TransportCode as nvarchar(50) 
as 
begin

	select 
		subquery.*,hdr_DeliveryResponse.DeliveryStatus
	from
		hdr_DeliveryResponse as hdr_DeliveryResponse
			join (select 
				hdrResponse.ExternalCode, hdrResponse.DeliveryNumber,  MAX(hdrResponse.RecordDate) as RecordDate
			from tbl_Transport as tblTr 
				join hdr_DeliveryResponse as hdrResponse
				on tblTr.DeliveryRequestCode = hdrResponse.ExternalCode
			where 
				tblTr.TransportCode = @TransportCode
			group by
				hdrResponse.ExternalCode, hdrResponse.DeliveryNumber) as subquery
		on hdr_DeliveryResponse.ExternalCode = subquery.ExternalCode
			and hdr_DeliveryResponse.RecordDate = subquery.RecordDate
	order by DeliveryNumber	

end;

GO

CREATE PROC repWarehouseSummary 
	@Owner nvarchar(max) = null, 
	@Materials nvarchar(max) = null,
	@MaterialGroups nvarchar(max) = null,
	@StockTypes nvarchar(max) = null 
AS
BEGIN
	
	declare @Query nvarchar(max)
	declare @filter nvarchar(max) = ''
	declare @StructureMaterialsParameterType_id nvarchar(15)
	declare @StructureMaterialUnitsParameterType_id nvarchar(15)

	set @StructureMaterialsParameterType_id = cast((select s.ParameterType_id from LEADWMS.dbo.Structures as s where Identifier = 'Materials') as nvarchar(200))
	set @StructureMaterialUnitsParameterType_id = cast((select s.ParameterType_id from LEADWMS.dbo.Structures as s where Identifier = 'MaterialUnits') as nvarchar(200))

	if @Owner is not null
		begin
			if CHARINDEX(',', @Owner) = 0
				set @filter = @filter + ' and i.tid = '+@Owner
			else
				set @filter = @filter + ' and i.tid in ('+@Owner+')'	
		end;

	if @Materials is not null
		begin
			if CHARINDEX(',', @Materials) = 0
				set @filter = @filter + ' and ws.Material_id = '+@Materials
			else
				set @filter = @filter + ' and ws.Material_id in ('+@Materials+')'	
		end;

	if @MaterialGroups is not null
		begin
			if CHARINDEX(',', @MaterialGroups) = 0
				set @filter = @filter + ' and m.MaterialGroup_id = '+@MaterialGroups
			else
				set @filter = @filter + ' and m.MaterialGroup_id in ('+@MaterialGroups+')'	
		end;

	if @StockTypes is not null
		begin
			if CHARINDEX(',', @StockTypes) = 0
				set @filter = @filter + ' and ws.StockType_id = '+@StockTypes
			else
				set @filter = @filter + ' and ws.StockType_id in ('+@StockTypes+')'	
		end;

	set @Query = 'select
		e.NameRU as TechnoZone,
		LEADWMS.dbo.ObjectLocation(c.tid) as StorageObject,
		ei_materials.TargetValue as Material_id,
		m.NameRu as Material,
		isnull(l.ShortName, l.NameRU) as Unit,
		ei_material_units.TargetValue as MaterialUnit_id,
		h.NameRU as StockType,
		ws.StockType_id as StockType_id,
		i.ShortName as OwnerStock,
		ws.BaseQuantity AS BaseQuantity,
		isnull(TRY_CONVERT(nvarchar(25), bo.ProdDate, 112), ''00010101'') as ProdDate,
		isnull(TRY_CONVERT(nvarchar(25), bo.ExpDate, 112), ''00010101'') as ExpDate
	from
		LEADWMS.dbo.WarehouseSummary as ws with (nolock)
		join LEADWMS.dbo.BarcodeObjects as bo with (nolock)
			on ws.BarcodeObject_id = bo.tid
		join LEADWMS.dbo.Debtors as i with (nolock) 
			on bo.OwnerDebtor_id = i.tid
		join LEADWMS.dbo.temp_ElementIntegration_'+@StructureMaterialsParameterType_id+' as ei_materials
			on ws.Material_id = ei_materials.LocalValue
		join LEADWMS.dbo.Materials as m with (nolock)
			on ws.Material_id = m.tid
		join LEADWMS.dbo.MaterialUnits as k with (nolock)
			on ws.MaterialUnit_id = k.tid
		join LEADWMS.dbo.temp_ElementIntegration_'+@StructureMaterialUnitsParameterType_id+' as ei_material_units
			on ws.MaterialUnit_id = ei_material_units.LocalValue
		join LEADWMS.dbo.Units as l with (nolock) 
			on k.Unit_id = l.tid
		join LEADWMS.dbo.StorageObjects as c with (nolock) 
			on ws.StorageObject_id = c.tid
		join LEADWMS.dbo.Locations as d with (nolock) 
			on c.Location_id = d.tid
		left join LEADWMS.dbo.TechnoZones as e with (nolock) 
			on d.Warehouse_id = e.Warehouse_id
			and isnull(d.ComplectationArea_id, -1) = isnull(e.ComplectationArea_id, -1)
			and d.StorageZone_id = e.StorageZone_id and d.RouteZone_id = e.RouteZone_id
		join LEADWMS.dbo.StockTypes as h with (nolock) 
			on ws.StockType_id = h.tid
	where
		ws.BaseQuantity > 0
		&filter 
	order by
		TechnoZone, Material'

set @Query = REPLACE(@Query, '&filter', @filter)
		
exec (@Query)

END;

GO

CREATE PROC Add_BatchNumbers 
	@ExternalCode nvarchar(70), @MaterialCode nvarchar(50), @BatchNumber nvarchar(200), @ExpirationDate date, @DocumentNumbers nvarchar(50), 
	@DOCNUM nvarchar(50), @DOC_SENDER nvarchar(50) = '1С', @DOC_RECEIVER nvarchar(50) = 'WMS', @autotest bit=0
AS
BEGIN
	
	if @autotest = 1
		return

	IF (select 1 where EXISTS (select ExternalCode from Materials where ExternalCode = @MaterialCode)) is null
				begin
					declare @TextErrorMsg nvarchar(max)				
					set @TextErrorMsg = CONCAT('Не найден материал с кодом: ', @MaterialCode);
					THROW 51000, @TextErrorMsg, 16
				end;
				
	INSERT INTO BatchNumbers (ExternalCode, MaterialCode, BatchNumber, ExpirationDate, DocumentNumbers, DOCNUM, DOC_SENDER, DOC_RECEIVER, RecordDate)
		VALUES (@ExternalCode, @MaterialCode, @BatchNumber, @ExpirationDate, @DocumentNumbers, @DOCNUM, @DOC_SENDER, @DOC_RECEIVER, GETDATE())

END;

GO

CREATE PROC Get_B2BDeleteHdrRequest AS
BEGIN
	
	select * from B2BDeleteHdrRequestLog where CHECKED_BY_PI is null

END;

GO

CREATE PROC Patch_B2BDeleteHdrRequest @ExternalCode nvarchar(50), @CHECKED_BY_PI datetime AS
BEGIN
	
	UPDATE B2BDeleteHdrRequestLog
	set CHECKED_BY_PI = @CHECKED_BY_PI
	where ExternalCode = @ExternalCode

END;


