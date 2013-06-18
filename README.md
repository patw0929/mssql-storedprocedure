mssql-storedprocedure
=====================

My Microsoft SQL Server stored procedure scripts in common use.

***

procDataSort
---
資料交換排序 (主索引為 sID, 排序值為 sSortid)


@tablename VARCHAR(50),		--表名

@inputId BIGINT,		--輸入索引

@inputAct CHAR(1),		--動作，是上移或下移

@sTypeID BIGINT = 0		--分類索引

***

procTypeSort
---
類別交換排序 (主索引為 sID, 排序值為 sSortid)


@tablename varchar(50),		--表名

@inputId INT,			--索引值

@inputAct CHAR(1)		--動作，是上移或下移


***

procInsertNews
---
新增資料 (以新增新聞資料為例) (主索引為 sID, 排序值為 sSortid)


@tablename varchar(50) = NULL,		--表名

@sID BIGINT = NULL,			--索引

@insertMode BIT = 0,			--模式 (1:新增)

@sTitle NVARCHAR(200),			--標題

@sContent NVARCHAR(MAX),		--內文

@sTypeID INT,				--分類索引

@sVisible BIT,				--是否顯示

@sTop BIT,				--是否置頂

@sStartEnable BIT,			--是否開啟上下架日期

@sStartDate SMALLDATETIME,		--上架日

@sEndDate SMALLDATETIME,		--下架日

@sReturnID BIGINT OUTPUT		--返回索引


***

procTypeInsert
---
新增分類資料 (主索引為 sID, 排序值為 sSortid)


@tablename varchar(20),			--表名

@sCaption nvarchar(100),		--名稱

@sVisible tinyint			--是否顯示


***

procSortidRefresh
---
當 sSortid 重複時，須執行的重新排序作業 (主索引為 sID, 排序值為 sSortid)


@tablename varchar(50)			--表名

