USE TRANSIT

go

print('Запущен процесс чистки таблицы BatchNumbers')
-- Проверка на существование времеменной таблицы
 IF OBJECT_ID('tmpBatchNumbers', 'U') is not null
	drop table #tmpBatchNumbers

-- Создаем временную таблицу, в которую поместим актуальные данные
CREATE TABLE #tmpBatchNumbers 
(
	ExternalCode nvarchar(50) not  null,
	MaterialCode nvarchar(50) not null,
	BatchNumber nvarchar(200) not null,
	ExpirationDate date null,
	DocumentNumbers varchar(50) not null,
	PROCESSED_DATE datetime null,
	PROCESSED_STATUS char(2) null,
	PROCESSED_COMMENT nvarchar(400),
	DOCNUM nvarchar(50) not null,
	DOC_SENDER nvarchar(50) not null,
	DOC_RECEIVER nvarchar(50) not null,
	CHECKED_BY_PI datetime null,
	RecordDate datetime null
)
-- Заполняем временную таблица
INSERT INTO #tmpBatchNumbers (ExternalCode, MaterialCode, BatchNumber, ExpirationDate, DocumentNumbers, PROCESSED_DATE, PROCESSED_STATUS, PROCESSED_COMMENT,
		DOCNUM, DOC_SENDER, DOC_RECEIVER, CHECKED_BY_PI, RecordDate)
select bn.ExternalCode, bn.MaterialCode, bn.BatchNumber, bn.ExpirationDate, bn.DocumentNumbers, bn.PROCESSED_DATE, bn.PROCESSED_STATUS, bn.PROCESSED_COMMENT,
		bn.DOCNUM, bn.DOC_SENDER, bn.DOC_RECEIVER, bn.CHECKED_BY_PI, bn.RecordDate
from BatchNumbers as bn
join (select ExternalCode, max(RecordDate) as RecordDate from BatchNumbers where CHECKED_BY_PI is not null and PROCESSED_STATUS = 'OK' group by ExternalCode) as LastRecord
on bn.ExternalCode = LastRecord.ExternalCode
	and bn.RecordDate = LastRecord.RecordDate
group by
	bn.ExternalCode, bn.MaterialCode, bn.BatchNumber, bn.ExpirationDate, bn.DocumentNumbers, bn.PROCESSED_DATE, bn.PROCESSED_STATUS, bn.PROCESSED_COMMENT,
		bn.DOCNUM, bn.DOC_SENDER, bn.DOC_RECEIVER, bn.CHECKED_BY_PI, bn.RecordDate
-- Выводим результат выполнения
-- Количество до
declare @CountUpTo int = (select count(*) from BatchNumbers)
print('Количество до: '+cast(@CountUpTo as nvarchar(50)))
-- Чистим таблицу
truncate table BatchNumbers


-- Загружаем данные из временной таблицы в физическую
INSERT INTO BatchNumbers(ExternalCode, MaterialCode, BatchNumber, ExpirationDate, DocumentNumbers, PROCESSED_DATE, PROCESSED_STATUS, PROCESSED_COMMENT,
		DOCNUM, DOC_SENDER, DOC_RECEIVER, CHECKED_BY_PI, RecordDate)
select * from #tmpBatchNumbers

-- Количество после
declare @CountAfter int = (select count(*) from BatchNumbers)
print('Количество после: '+cast(@CountAfter as nvarchar(50)))
-- Удаляем временную таблицу
drop table #tmpBatchNumbers



