select subq.tid, subq.PROCESSED_DATE, subq.PROCESSED_STATUS, subq.PROCESSED_COMMENT, subq.DOCNUM, subq.DOC_SENDER, subq.DOC_RECEIVER, subq.CHECKED_BY_PI, 
subq.RecordDate, subq.PREV_CHECKED_BY_PI, DATEPART(ss, subq.CHECKED_BY_PI - subq.PREV_CHECKED_BY_PI) as [Время выполнения в секундах] 
from 
(select *, (select CHECKED_BY_PI from DOCNUM as d2 where DOC_SENDER = '1С' and d2.tid = d.tid-1) as PREV_CHECKED_BY_PI  
from DOCNUM as d  where DOC_SENDER = '1С' and RecordDate between '19-08-2020 16:10:00' and '19-08-2020 17:00:00' and CHECKED_BY_PI is not null) as subq
where subq.PREV_CHECKED_BY_PI is not null
order by subq.RecordDate