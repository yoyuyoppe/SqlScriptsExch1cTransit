
USE TRANSIT

GO

create table #tempArchiveKM
(	
	[tid] [bigint] IDENTITY(1,1) NOT NULL,
	[ExternalCode] [nvarchar](200) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[MaterialCode] [nvarchar](200) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[KI] [nvarchar](500) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[KIGU] [nvarchar](500) COLLATE Cyrillic_General_CI_AS NULL,
	[KITU] [nvarchar](500) COLLATE Cyrillic_General_CI_AS NULL,
	[SSCC] [nvarchar](500) COLLATE Cyrillic_General_CI_AS NULL,
	[StatusKI] [nvarchar](200) COLLATE Cyrillic_General_CI_AS NULL,
	[RecordDate] [datetime] NOT NULL,
	[PROCESSED_DATE] [datetime] NULL,
	[PROCESSED_STATUS] [nchar](2) COLLATE Cyrillic_General_CI_AS NULL,
	[PROCESSED_COMMENT] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[DOCNUM] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[DOC_SENDER] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[DOC_RECEIVER] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[CHECKED_BY_PI] [datetime] NULL	
)

GO

BULK INSERT #tempArchiveKM 
FROM '\\10.50.0.3\for_wms\obmenTRANSIT\Files\Марки_отгружены_2023\tbl_ArchiveKM_Егаис_23.csv'
WITH (FIRSTROW = 1,CODEPAGE = '1251', DATAFILETYPE = 'char',FIELDTERMINATOR = '	' , ROWTERMINATOR = '\n')

GO


INSERT INTO tbl_ArchiveKM (ExternalCode, MaterialCode, KI, KIGU, KITU, SSCC, StatusKI, DOC_SENDER, DOC_RECEIVER, RecordDate, DOCNUM)
select distinct tempArchiveKM.ExternalCode, tempArchiveKM.MaterialCode, tempArchiveKM.KI, tempArchiveKM.KIGU, tempArchiveKM.KITU, tempArchiveKM.SSCC, 
tempArchiveKM.StatusKI, tempArchiveKM.DOC_SENDER, tempArchiveKM.DOC_RECEIVER, tempArchiveKM.RecordDate, tempArchiveKM.DOCNUM
from #tempArchiveKM as tempArchiveKM
join LEADWMS.dbo.temp_ElementIntegration_65 as Materials
on tempArchiveKM.MaterialCode = Materials.TargetValue

GO

--exec Add_DocNum @DocNum = 'cda90bcb-7a8d-4f54-80f5-8a426a2a341b', @autotest = 0 - лидовцы сказала, чтобы не добавляли ид пакеты в таблицу DOCNUM

--truncate table #tempArchiveKM

--drop table #tempArchiveKM
