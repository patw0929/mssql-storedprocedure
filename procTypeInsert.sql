SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- �W��:		procTypeInsert
-- �̫�׭q:	2013/05/06
-- ����:		��x �椸��������Ʒs�W
-- =================================================================
CREATE procedure [dbo].[procTypeInsert] 
(
@tablename varchar(20),				--��W
@sCaption nvarchar(100),			--�W��
@sVisible tinyint					--�O�_���
)
as

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)
DECLARE @sSortid INT

--���osortid
set @ExecuteSQL = 'SELECT @sSortid = MAX(sSortid)+1 FROM '+@tablename;
set @ExecuteParam = '@sSortid INT OUTPUT';
EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sSortid=@sSortid OUTPUT

set @sSortid = ISNULL(@sSortid, 1);

--�s�Wtype
set @ExecuteSQL = 'INSERT INTO '+@tablename+' (sCaption, sVisible, sSortid) VALUES(@sCaption, @sVisible, @sSortid)';
set @ExecuteParam = '@sCaption NVARCHAR(100), @sVisible TINYINT, @sSortid INT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sCaption, @sVisible, @sSortid
GO


