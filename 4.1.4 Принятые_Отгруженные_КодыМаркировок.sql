
CREATE PROC GetDeliveryResponseMarks
	@DocNum nvarchar(50),
	@Update bit = 0
as

begin
		
	select
		null as ExternalCode,
	    tdrm.DeliveryRequestCode as DeliveryRequestCode,  
	    null as DeliveryRequestRowCode,
	    null as KI,
		null as KIGU,
		null as KITU,
		null as SSCC,
	    tdrm.PROCESSED_COMMENT as Comment,
		tdrm.DOCNUM
	from
	    tbl_DeliveryResponseMarks tdrm 
	where 
	    tdrm.DOCNUM = @DocNum
	group by
	    tdrm.DeliveryRequestCode,
	    tdrm.PROCESSED_COMMENT,
		tdrm.DOCNUM
	HAVING
		MAX(IIF(tdrm.CHECKED_BY_PI is null, 0, 1)) = @Update	
	
	union
	
	select
		tdrm.ExternalCode,
	    tdrm.DeliveryRequestCode as DeliveryRequestCode,  
	    tdrm.DeliveryRequestRowCode,
	    tdrm.KI,
		tdrm.KIGU,
		tdrm.KITU,
		tdrm.SSCC,
	    tdrm.PROCESSED_COMMENT as Comment,
		tdrm.DOCNUM
	from
	    tbl_DeliveryResponseMarks tdrm 
	where 
	    tdrm.DOCNUM = @DocNum
	group by
		tdrm.ExternalCode,
	    tdrm.DeliveryRequestCode,  
	    tdrm.DeliveryRequestRowCode,
	    tdrm.KI,
		tdrm.KIGU,
		tdrm.KITU,
		tdrm.SSCC,
	    tdrm.PROCESSED_COMMENT,
		tdrm.DOCNUM
	HAVING
		MAX(IIF(tdrm.CHECKED_BY_PI is null, 0, 1)) = @Update
	order by
		DeliveryRequestCode, ExternalCode
	
end


	
	