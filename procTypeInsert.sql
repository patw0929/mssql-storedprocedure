SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- 名稱:		procTypeInsert
-- 最後修訂:	2013/05/06
-- 說明:		後台 單元分類的資料新增
-- =================================================================
CREATE procedure [dbo].[procTypeInsert] 
(
@tablename varchar(20),				--表名
@sCaption nvarchar(100),			--名稱
@sVisible tinyint					--是否顯示
)
as

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)
DECLARE @sSortid INT

--取得sortid
set @ExecuteSQL = 'SELECT @sSortid = MAX(sSortid)+1 FROM '+@tablename;
set @ExecuteParam = '@sSortid INT OUTPUT';
EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sSortid=@sSortid OUTPUT

set @sSortid = ISNULL(@sSortid, 1);

--新增type
set @ExecuteSQL = 'INSERT INTO '+@tablename+' (sCaption, sVisible, sSortid) VALUES(@sCaption, @sVisible, @sSortid)';
set @ExecuteParam = '@sCaption NVARCHAR(100), @sVisible TINYINT, @sSortid INT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sCaption, @sVisible, @sSortid
GO


