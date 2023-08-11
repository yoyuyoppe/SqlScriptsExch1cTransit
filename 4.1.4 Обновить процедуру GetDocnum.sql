ALTER PROC

	[dbo].[GetDocnum] @filter nvarchar(max)
as

begin
	
	declare @query nvarchar(max) = '
	select 
		CASE
			WHEN hdr_dr.tid is null THEN 0
			ELSE 1
		END AS type_response,
	docnum.docnum, docnum.PROCESSED_DATE as proc_date, docnum.PROCESSED_STATUS as proc_status, CAST(docnum.PROCESSED_COMMENT AS nvarchar(100)) as comment, docnum.CHECKED_BY_PI as proc_date_beg, docnum.RecordDate
	from DOCNUM as docnum with (nolock)
	left join hdr_DeliveryResponse as hdr_dr with (nolock)
	on docnum.DOCNUM = hdr_dr.DOCNUM
	where &filter
	'; 

	set @query = REPLACE(@query, '&filter', @filter)
			
	exec (@query);

end;