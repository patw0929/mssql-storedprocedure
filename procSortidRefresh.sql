SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- �W��:		procSortidRefresh
-- �̫�׭q:	2013/04/18
-- ����:		��x �Ƨ� sortid �Y�͵o���ơA�h���歫�Ƨ@�~
-- =================================================================
CREATE PROCEDURE [dbo].[procSortidRefresh]
	(
	@tablename varchar(50)			--��W
	)
AS

declare @ExecuteSQL nvarchar(1000);

--���s�Ư��޸��A��X�\��sortid

CREATE TABLE #tmp (sID bigint, sSortidTmp bigint)

set @ExecuteSQL = 'INSERT INTO #tmp SELECT sID, ROW_NUMBER() OVER (ORDER BY sSortid, sID ASC) FROM '+@tablename;
EXEC sp_executesql @ExecuteSQL

set @ExecuteSQL = 'UPDATE '+@tablename+' SET '+@tablename+'.sSortid = (SELECT sSortidTmp FROM #tmp WHERE #tmp.sID='+@tablename+'.sID);DROP TABLE #tmp';
EXEC sp_executesql @ExecuteSQL
GO


