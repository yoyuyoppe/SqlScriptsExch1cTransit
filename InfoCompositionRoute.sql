select
	[Номер маршрута] = VL.RouteNumber,
	[Транспорт] = VL.VehicleBrand,
	[ГосНомер] = VL.VehicleNumber,
	[Номер заказа] = hdr.ExternalCode, 
	[Мастер ОС] = SOM.Barcode,
	[Дочерний ОС] = SO.Barcode,
	[Артикул] = M.NameEN,
	[Штрихкод] = MAX(MUB.Barcode),
	[Материал] = M.NameRU,
	[Годен до] = BO.ExpDate,
	[Количество] = lower(cast(dbo.CutZeroTale(TPL.BaseQuantity/ mu.UnitKoeff) as nvarchar(max))),
	[Единица измерения] = u.ShortName
from hdr_DeliveryRequest as HDR
		inner join Transactions as T with (nolock) on T.ParentTransaction_id = HDR.Transaction_id
		inner join Transactions as T2 with (nolock) on T2.ParentTransaction_id = T.tid
		inner join tbl_PackingList as TPL with (nolock) on TPL.Transaction_id = T2.tid
		left join VisitorsLog as VL with (nolock) on VL.Route_id = HDR.OriginalRoute_id
		left join VisitorsLog as VL2 with (nolock) on VL2.Route_id = HDR.OrderRoute_id
		inner join hdr_Consolidation as HC with (nolock) on HC.Visitor_id = isnull(VL.tid, VL2.tid)
		inner join tbl_ConsolidationTare as TCT with (nolock) on TCT.Consolidation_id = HC.tid
		inner join tbl_ConsolidationAllocation as TCA with (nolock) on TCA.ConsolidationTare_id = TCT.tid
			and TCA.StorageObject_id = TPL.StorageObject_id
		inner join StorageObjects as SO with (nolock) on SO.tid = TCA.StorageObject_id
		inner join StorageObjects as SOM with (nolock) on SOM.tid = TCT.StorageObject_id
		inner join BarcodeObjects as BO with (nolock) on BO.tid = TPL.BarcodeObject_id
		inner join Materials as M with (nolock) on M.tid = TPL.Material_id
		inner join MaterialUnits as MU with (nolock) on MU.tid = TPL.MaterialUnit_id
		inner join Units as U (nolock) on MU.unit_id = U.tid
		left join MaterialUnitBarcodes as MUB
		on MUB.MaterialUnit_id = MU.tid
where hdr.DeliveryDate = '17-09-2021' and hdr.DebtorPartner_id = 7467
group by
	VL.RouteNumber,
	VL.VehicleBrand,
	VL.VehicleNumber,
	hdr.ExternalCode, 
	SOM.Barcode,
	SO.Barcode,
	M.NameEN,
	M.NameRU,
	BO.ExpDate,
	u.ShortName,
	lower(cast(dbo.CutZeroTale(TPL.BaseQuantity/ mu.UnitKoeff) as nvarchar(max)))
order by hdr.ExternalCode

--select top 10 * from hdr_DeliveryRequest where ExternalCode = 'ТШЦ1295037'

--select top 10 * from VisitorsLog where RouteNumber = 'Ц000042335'

--select top 100  * from MaterialUnitBarcodes