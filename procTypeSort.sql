SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- �W��:		procTypeSort
-- �̫�׭q:	2013/04/18
-- ����:		��x �椸�������ƧǳB�z
-- =================================================================
CREATE procedure [dbo].[procTypeSort] 
(
@tablename varchar(50),		--��W
@inputId INT,				--���ޭ�
@inputAct CHAR(1)			--�ʧ@�A�O�W���ΤU��
)
as

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)

DECLARE @OrgSerial INT
DECLARE @OrgSortid INT
DECLARE @TargetId INT
DECLARE @TargetSortid INT
DECLARE @op BIGINT

--���o��JID��sortid �� Serial
set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid ASC) AS Serial FROM '+@tablename+') AS Thread WHERE sID = @inputId';
set @ExecuteParam = '@inputId INT, @OrgSerial INT OUTPUT, @OrgSortid INT OUTPUT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

--���o�ت�ID �� sortid
if(@inputAct = 'u' AND @OrgSerial > 1)
	set @OrgSerial=@OrgSerial-1;
if(@inputAct = 'd')
	set @OrgSerial=@OrgSerial+1;

SET @ExecuteSQL = 'SELECT @TargetId=sID, @TargetSortid=sSortid FROM
	(SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid ASC) AS Serial FROM '+@tablename+') AS Thread WHERE Thread.Serial = @OrgSerial';
SET @ExecuteParam = '@OrgSerial INT, @TargetId INT OUTPUT, @TargetSortid INT OUTPUT';

EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSerial, @TargetId=@TargetId OUTPUT, @TargetSortid=@TargetSortid OUTPUT

--�p�G�o�{��� sortid �ۦP�A�h�N�Ӫ�Ҧ� sortid ����
if(@TargetSortid=@OrgSortid)
	BEGIN
		EXEC procSortidRefresh @tablename
	END
else
BEGIN

	if(@TargetId IS NOT NULL)
		BEGIN
			--��s���
			set @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@TargetSortid WHERE sID=@inputId';
			set @ExecuteParam = '@TargetSortid INT, @inputId INT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @TargetSortid, @inputId

			set @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@OrgSortid WHERE sID=@TargetId';
			set @ExecuteParam = '@OrgSortid INT, @TargetId INT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSortid, @TargetId
		END

END
GO
