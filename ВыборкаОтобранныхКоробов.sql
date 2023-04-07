declare @ExtCode nvarchar(25) = 'หรฮ0050481';

select distinct
	bo.barcode
from (select 
	isnull(SO.Barcode, pl.StorageObjectName) as barcode
from
	LEADWMS.dbo.hdr_DeliveryRequest as hdr
	left join LEADWMS.dbo.tbl_DeliveryRequestMaterials as tbl
	on hdr.Transaction_id = tbl.Transaction_id
	left join LEADWMS.dbo.StorageObjects as SO
	on tbl.DeliveryTransaction_id = SO.DeliveryTransaction_id
	left join LEADWMS.dbo.tbl_PackingList as pl
	on tbl.tid = pl.RequestRow_id
where
	hdr.ExternalCode = @ExtCode) as bo
where bo.barcode is not null