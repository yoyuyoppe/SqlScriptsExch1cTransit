USE TRANSITTEST

go

if OBJECT_ID('tbl_DeliveryRequestMarks', 'U') is null
begin

	create table tbl_DeliveryRequestMarks(
		tid int primary key identity,
		ExternalCode nvarchar(200) UNIQUE,
		DeliveryRequestCode nvarchar(200) not null UNIQUE,
		DeliveryRequestRowCode nvarchar(200) not null UNIQUE,
		KI nvarchar(200) not null UNIQUE,
		KIGU nvarchar(200),
		KITU nvarchar(200),
		SSCC nvarchar(200),
		RecordDate datetime not null
	);

end;


if OBJECT_ID('Add_tblDeliveryRequestMarks', 'P') is not null
drop procedure Add_tblDeliveryRequestMarks

go

	create proc Add_tblDeliveryRequestMarks
		@ExternalCode nvarchar(200),
		@DeliveryRequestCode nvarchar(200),
		@DeliveryRequestRowCode nvarchar(200),
		@KI nvarchar(200),
		@KIGU nvarchar(200) = null,
		@KITU nvarchar(200) = null,
		@SSCC nvarchar(200) = null,
		@autotest bit = 0
	as
			
	begin
			
		if @autotest = 1
			return

		declare @TextErrorMsg nvarchar(max)

		IF (select 1 where EXISTS (select ExternalCode from hdr_DeliveryRequest where ExternalCode = @DeliveryRequestCode)) is null
			begin
				set @TextErrorMsg = CONCAT('(51010) Не найдена заявка с кодом: #!', @DeliveryRequestCode);
				THROW 51010, @TextErrorMsg, 16
			end;

		IF (select 1 where EXISTS (select ExternalCode from tbl_DeliveryRequest where ExternalCode = @DeliveryRequestRowCode)) is null
			begin
				set @TextErrorMsg = CONCAT('(51012) Не найдена строка заявки: #!', @DeliveryRequestRowCode);
				THROW 51012, @TextErrorMsg, 16
			end;

		insert into tbl_DeliveryRequestMarks (ExternalCode, DeliveryRequestCode, DeliveryRequestRowCode, KI, KIGU, KITU, SSCC, RecordDate)
		values (@ExternalCode, @DeliveryRequestCode, @DeliveryRequestRowCode, @KI, @KIGU, @KITU, @SSCC, GetDate())


		return

	end
