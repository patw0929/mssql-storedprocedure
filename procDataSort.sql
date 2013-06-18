SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =================================================================
-- �W��:		procDataSort
-- �̫�׭q:	2013/04/19
-- ����:		��x �峹��ƱƧǳB�z
-- =================================================================
CREATE procedure [dbo].[procDataSort] 
(
@tablename VARCHAR(50),				--��W
@inputId BIGINT,					--��J����
@inputAct CHAR(1),					--�ʧ@�A�O�W���ΤU��
@sTypeID BIGINT = 0					--��������
)
AS

DECLARE @ExecuteSQL NVARCHAR(1000)
DECLARE @ExecuteParam NVARCHAR(1000)

DECLARE @OrgSerial BIGINT
DECLARE @OrgSortid BIGINT
DECLARE @TargetId BIGINT
DECLARE @TargetSortid BIGINT

--�p�������A�h�[�W����������A���Ƨǥ洫
if(@sTypeID <> 0)
	BEGIN

			DECLARE @sTop BIT

			--���o��J sID ���m���ΫD�m��
			set @ExecuteSQL = 'SELECT @sTop=sTop FROM '+@tablename+' WHERE sID = @inputId AND sTypeID = @sTypeID';
			set @ExecuteParam = '@inputId BIGINT, @sTypeID BIGINT, @sTop BIT OUTPUT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @sTypeID, @sTop=@sTop OUTPUT
		
			--���o��J sID �� sSortid �� Serial
			set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
			 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sTop DESC, sSortid DESC) AS Serial FROM '+@tablename+' WHERE sTop = @sTop AND sTypeID = @sTypeID
			 ) AS Thread WHERE sID = @inputId';
			set @ExecuteParam = '@sTop BIT, @inputId BIGINT, @sTypeID BIGINT, @OrgSerial BIGINT OUTPUT, @OrgSortid BIGINT OUTPUT';

			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sTop, @inputId, @sTypeID, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

			--���o�ت� sID �� sSortid
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
else --�Ϥ��A�L�����A�h���ݥ[�W��������A�����洫�Ƨ�
	BEGIN

		--���o��JID�� sSortid �� Serial
		set @ExecuteSQL = 'SELECT @OrgSerial=Thread.Serial, @OrgSortid=sSortid FROM
		 (SELECT sID, sSortid, ROW_NUMBER() OVER (ORDER BY sSortid DESC) AS Serial FROM '+@tablename+') AS Thread WHERE sID = @inputId';
		set @ExecuteParam = '@inputId BIGINT, @OrgSerial BIGINT OUTPUT, @OrgSortid BIGINT OUTPUT';

		EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @inputId, @OrgSerial=@OrgSerial OUTPUT, @OrgSortid=@OrgSortid OUTPUT

		--���o�ت� sID �� sSortid
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


--�p�G�o�{��� sortid �ۦP�A�h�N�Ӫ�Ҧ� sortid ����
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

				--��s���
				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@TargetSortid WHERE sID=@inputId AND sTypeID = @sTypeID';
				SET @ExecuteParam = '@TargetSortid BIGINT, @inputId BIGINT, @sTypeID BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @TargetSortid, @inputId, @sTypeID

				SET @ExecuteSQL = 'UPDATE '+@tablename+' SET sSortid=@OrgSortid WHERE sID=@TargetId AND sTypeID = @sTypeID';
				SET @ExecuteParam = '@OrgSortid BIGINT, @TargetId BIGINT, @sTypeID BIGINT';
				EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @OrgSortid, @TargetId, @sTypeID

			END
			else
			BEGIN

				--��s���
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


