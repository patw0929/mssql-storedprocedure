SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- 名稱:		procSortidRefresh
-- 最後修訂:	2013/04/18
-- 說明:		後台 排序 sortid 若生發重複，則執行重排作業
-- =================================================================
CREATE PROCEDURE [dbo].[procSortidRefresh]
	(
	@tablename varchar(50)			--表名
	)
AS

declare @ExecuteSQL nvarchar(1000);

--重新排索引號，輸出蓋掉sortid

CREATE TABLE #tmp (sID bigint, sSortidTmp bigint)

set @ExecuteSQL = 'INSERT INTO #tmp SELECT sID, ROW_NUMBER() OVER (ORDER BY sSortid, sID ASC) FROM '+@tablename;
EXEC sp_executesql @ExecuteSQL

set @ExecuteSQL = 'UPDATE '+@tablename+' SET '+@tablename+'.sSortid = (SELECT sSortidTmp FROM #tmp WHERE #tmp.sID='+@tablename+'.sID);DROP TABLE #tmp';
EXEC sp_executesql @ExecuteSQL
GO


