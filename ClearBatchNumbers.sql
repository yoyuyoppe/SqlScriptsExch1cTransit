USE TRANSIT

go

print('������� ������� ������ ������� BatchNumbers')
-- �������� �� ������������� ����������� �������
 IF OBJECT_ID('tmpBatchNumbers', 'U') is not null
	drop table #tmpBatchNumbers

-- ������� ��������� �������, � ������� �������� ���������� ������
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
-- ��������� ��������� �������
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
-- ������� ��������� ����������
-- ���������� ��
declare @CountUpTo int = (select count(*) from BatchNumbers)
print('���������� ��: '+cast(@CountUpTo as nvarchar(50)))
-- ������ �������
truncate table BatchNumbers


-- ��������� ������ �� ��������� ������� � ����������
INSERT INTO BatchNumbers(ExternalCode, MaterialCode, BatchNumber, ExpirationDate, DocumentNumbers, PROCESSED_DATE, PROCESSED_STATUS, PROCESSED_COMMENT,
		DOCNUM, DOC_SENDER, DOC_RECEIVER, CHECKED_BY_PI, RecordDate)
select * from #tmpBatchNumbers

-- ���������� �����
declare @CountAfter int = (select count(*) from BatchNumbers)
print('���������� �����: '+cast(@CountAfter as nvarchar(50)))
-- ������� ��������� �������
drop table #tmpBatchNumbers



