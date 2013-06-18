SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =================================================================
-- 名稱:		procInsertNews
-- 最後修訂:	2013/05/20
-- 說明:		後台 新增/修改 最新消息
-- =================================================================
CREATE PROCEDURE [dbo].[procInsertNews]
	@tablename varchar(50) = NULL,		--表名
	@sID BIGINT = NULL,					--索引
	@insertMode BIT = 0,				--模式 (1:新增)
	@sTitle NVARCHAR(200),				--標題
	@sContent NVARCHAR(MAX),			--內文
	@sTypeID INT,						--分類索引
	@sVisible BIT,						--是否顯示
	@sTop BIT,							--是否置頂
	@sStartEnable BIT,					--是否開啟上下架日期
	@sStartDate SMALLDATETIME,			--上架日
	@sEndDate SMALLDATETIME,			--下架日
    @sReturnID BIGINT OUTPUT			--返回索引
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @ExecuteSQL NVARCHAR(1000);
	DECLARE @ExecuteParam NVARCHAR(1000);
	SET NOCOUNT ON;

	if (@insertMode=1)
		BEGIN

			--取得最大 sSortid
			DECLARE @sSortid INT

			--取得sortid
			SET @ExecuteSQL = 'SELECT @sSortid = MAX(sSortid)+1 FROM '+@tablename+' WHERE sTypeID=@sTypeID';
			SET @ExecuteParam = '@sTypeID BIGINT, @sSortid INT OUTPUT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sTypeID, @sSortid=@sSortid OUTPUT

			SET @sSortid = ISNULL(@sSortid, 1);


			--再新增資料
			SET @ExecuteSQL = 'INSERT INTO ' + @tablename + ' (sTitle, sContent, sTypeID, sVisible, sTop, sSortid, sStartEnable, sStartDate, sEndDate) ';
			SET @ExecuteSQL = @ExecuteSQL + ' VALUES ( @sTitle, @sContent, @sTypeID, @sVisible, @sTop, @sSortid, @sStartEnable, @sStartDate, @sEndDate);';
			SET @ExecuteSQL = @ExecuteSQL + 'SET @sReturnID = SCOPE_IDENTITY();';
			SET @ExecuteParam = '@sTitle NVARCHAR(200), @sContent NVARCHAR(MAX), @sTypeID INT, ';
			SET @ExecuteParam = @ExecuteParam + '@sVisible BIT, @sTop BIGINT, @sSortid BIGINT, @sStartEnable BIT, @sStartDate SMALLDATETIME, @sEndDate SMALLDATETIME, @sReturnID BIGINT OUTPUT';

			EXECUTE sp_executesql @ExecuteSQL, @ExecuteParam, @sTitle, @sContent, @sTypeID, @sVisible, @sTop, @sSortid, @sStartEnable, @sStartDate, @sEndDate, @sReturnID OUTPUT

			SELECT @sReturnID

		END
	else
		BEGIN

			SET @ExecuteSQL = 'UPDATE ' + @tablename + ' SET sTitle=@sTitle, sContent=@sContent, sTypeID=@sTypeID, sVisible=@sVisible, sTop=@sTop, ';
			SET @ExecuteSQL = @ExecuteSQL + 'sStartEnable=@sStartEnable, sStartDate=@sStartDate, sEndDate=@sEndDate ';
			SET @ExecuteSQL = @ExecuteSQL + ' WHERE sID=@sID';

			SET @ExecuteParam = '@sTitle NVARCHAR(200), @sContent NVARCHAR(MAX), @sTypeID INT, ';
			SET @ExecuteParam = @ExecuteParam + '@sVisible BIT, @sTop BIGINT, @sStartEnable BIT, @sStartDate SMALLDATETIME, @sEndDate SMALLDATETIME, @sID BIGINT';

			EXECUTE sp_executesql @ExecuteSQL, @ExecuteParam, @sTitle, @sContent, @sTypeID, @sVisible, @sTop, @sStartEnable, @sStartDate, @sEndDate, @sID

		END

END
GO


