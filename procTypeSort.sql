SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- 名稱:		procTypeSort
-- 最後修訂:	2013/04/18
-- 說明:		後台 單元分類的排序處理
-- =================================================================
CREATE procedure [dbo].[procTypeSort] 
(
@tablename varchar(50),		--表名
@inputId INT,				--索引值
@inputAct CHAR(1)			--動作，是上移或下移
)
as

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)

DECLARE @OrgSerial INT
DECLARE @OrgSortid INT
DECLARE @TargetId INT
DECLARE @TargetSortid INT
DECLARE @op BIGINT

--取得輸入ID的sortid 及 Serial
set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid ASC) AS Serial FROM '+@tablename+') AS Thread WHERE sID = @inputId';
set @ExecuteParam = '@inputId INT, @OrgSerial INT OUTPUT, @OrgSortid INT OUTPUT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

--取得目的ID 及 sortid
if(@inputAct = 'u' AND @OrgSerial > 1)
	set @OrgSerial=@OrgSerial-1;
if(@inputAct = 'd')
	set @OrgSerial=@OrgSerial+1;

SET @ExecuteSQL = 'SELECT @TargetId=sID, @TargetSortid=sSortid FROM
	(SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid ASC) AS Serial FROM '+@tablename+') AS Thread WHERE Thread.Serial = @OrgSerial';
SET @ExecuteParam = '@OrgSerial INT, @TargetId INT OUTPUT, @TargetSortid INT OUTPUT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSerial, @TargetId=@TargetId OUTPUT, @TargetSortid=@TargetSortid OUTPUT

--如果發現兩者 sortid 相同，則將該表所有 sortid 重排
if(@TargetSortid=@OrgSortid)
	BEGIN
		EXEC procSortidRefresh @tablename
	END
else
BEGIN

	if(@TargetId IS NOT NULL)
		BEGIN
			--更新資料
			set @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@TargetSortid WHERE sID=@inputId';
			set @ExecuteParam = '@TargetSortid INT, @inputId INT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @TargetSortid, @inputId

			set @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@OrgSortid WHERE sID=@TargetId';
			set @ExecuteParam = '@OrgSortid INT, @TargetId INT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSortid, @TargetId
		END

END
GO
