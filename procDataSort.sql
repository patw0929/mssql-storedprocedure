SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- 名稱:		procDataSort
-- 最後修訂:	2013/04/19
-- 說明:		後台 文章資料排序處理
-- =================================================================
CREATE procedure [dbo].[procDataSort] 
(
@tablename VARCHAR(50),				--表名
@inputId BIGINT,					--輸入索引
@inputAct CHAR(1),					--動作，是上移或下移
@sTypeID BIGINT = 0					--分類索引
)
AS

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)

DECLARE @OrgSerial BIGINT
DECLARE @OrgSortid BIGINT
DECLARE @TargetId BIGINT
DECLARE @TargetSortid BIGINT

--如有分類，則加上分類的條件再做排序交換
if(@sTypeID <> 0)
	BEGIN

			DECLARE @sTop BIT

			--取得輸入 sID 為置頂或非置頂
			set @ExecuteSQL = 'SELECT @sTop=sTop FROM '+@tablename+' WHERE sID = @inputId AND sTypeID = @sTypeID';
			set @ExecuteParam = '@inputId BIGINT, @sTypeID BIGINT, @sTop BIT OUTPUT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @sTypeID, @sTop=@sTop OUTPUT
		
			--取得輸入 sID 的 sSortid 及 Serial
			set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
			 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sTop DESC, sSortid DESC) AS Serial FROM '+@tablename+' WHERE sTop = @sTop AND sTypeID = @sTypeID
			 ) AS Thread WHERE sID = @inputId';
			set @ExecuteParam = '@sTop BIT, @inputId BIGINT, @sTypeID BIGINT, @OrgSerial BIGINT OUTPUT, @OrgSortid BIGINT OUTPUT';

			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sTop, @inputId, @sTypeID, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

			--取得目的 sID 及 sSortid
			if(@inputAct = 'u' AND @OrgSerial > 1)
				set @OrgSerial=@OrgSerial-1;
			if(@inputAct = 'd')
				set @OrgSerial=@OrgSerial+1;

			set @ExecuteSQL = 'SELECT @TargetId=sID, @TargetSortid=sSortid FROM
				(SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sTop DESC, sSortid DESC) AS Serial FROM '+@tablename+' WHERE sTop = @sTop AND sTypeID = @sTypeID
				) AS Thread WHERE Thread.Serial = @OrgSerial';
			set @ExecuteParam = '@sTop BIT, @sTypeID BIGINT, @OrgSerial BIGINT, @TargetId BIGINT OUTPUT, @TargetSortid BIGINT OUTPUT';

			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sTop, @sTypeID, @OrgSerial, @TargetId=@TargetId OUTPUT, @TargetSortid=@TargetSortid OUTPUT
	
	
	END
else --反之，無分類，則不需加上分類條件，直接交換排序
	BEGIN

		--取得輸入ID的 sSortid 及 Serial
		set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
		 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid DESC) AS Serial FROM '+@tablename+') AS Thread WHERE sID = @inputId';
		set @ExecuteParam = '@inputId BIGINT, @OrgSerial BIGINT OUTPUT, @OrgSortid BIGINT OUTPUT';

		EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

		--取得目的 sID 及 sSortid
		if(@inputAct = 'u' AND @OrgSerial > 1)
			set @OrgSerial=@OrgSerial-1;
		if(@inputAct = 'd')
			set @OrgSerial=@OrgSerial+1;

		set @ExecuteSQL = 'SELECT @TargetId=sID, @TargetSortid=sSortid FROM
			(SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid DESC) AS Serial FROM '+@tablename+') AS Thread 
			WHERE Thread.Serial = @OrgSerial';
		set @ExecuteParam = '@OrgSerial BIGINT, @TargetId BIGINT OUTPUT, @TargetSortid BIGINT OUTPUT';

		EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSerial, @TargetId=@TargetId OUTPUT, @TargetSortid=@TargetSortid OUTPUT

	END


--如果發現兩者 sortid 相同，則將該表所有 sortid 重排
if(@TargetSortid=@OrgSortid)
	BEGIN
		EXEC procSortidRefresh @tablename
	END
else
	BEGIN

		if(@TargetId IS NOT NULL)
		BEGIN

			if(@sTypeID <> 0)
			BEGIN

				--更新資料
				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@TargetSortid WHERE sID=@inputId AND sTypeID = @sTypeID';
				SET @ExecuteParam = '@TargetSortid BIGINT, @inputId BIGINT, @sTypeID BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @TargetSortid, @inputId, @sTypeID

				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@OrgSortid WHERE sID=@TargetId AND sTypeID = @sTypeID';
				SET @ExecuteParam = '@OrgSortid BIGINT, @TargetId BIGINT, @sTypeID BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSortid, @TargetId, @sTypeID

			END
			else
			BEGIN

				--更新資料
				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@TargetSortid WHERE sID=@inputId';
				SET @ExecuteParam = '@TargetSortid BIGINT, @inputId BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @TargetSortid, @inputId

				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@OrgSortid WHERE sID=@TargetId';
				SET @ExecuteParam = '@OrgSortid BIGINT, @TargetId BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSortid, @TargetId

			END

		END

	END
GO


