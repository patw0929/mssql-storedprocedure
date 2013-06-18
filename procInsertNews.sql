SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =================================================================
-- �W��:		procInsertNews
-- �̫�׭q:	2013/05/20
-- ����:		��x �s�W/�ק� �̷s����
-- =================================================================
CREATE PROCEDURE [dbo].[procInsertNews]
	@tablename varchar(50) = NULL,		--��W
	@sID BIGINT = NULL,					--����
	@insertMode BIT = 0,				--�Ҧ� (1:�s�W)
	@sTitle NVARCHAR(200),				--���D
	@sContent NVARCHAR(MAX),			--����
	@sTypeID INT,						--��������
	@sVisible BIT,						--�O�_���
	@sTop BIT,							--�O�_�m��
	@sStartEnable BIT,					--�O�_�}�ҤW�U�[���
	@sStartDate SMALLDATETIME,			--�W�[��
	@sEndDate SMALLDATETIME,			--�U�[��
    @sReturnID BIGINT OUTPUT			--��^����
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @ExecuteSQL NVARCHAR(1000);
	DECLARE @ExecuteParam NVARCHAR(1000);
	SET NOCOUNT ON;

	if (@insertMode=1)
		BEGIN

			--���o�̤j sSortid
			DECLARE @sSortid INT

			--���osortid
			SET @ExecuteSQL = 'SELECT @sSortid = MAX(sSortid)+1 FROM '+@tablename+' WHERE sTypeID=@sTypeID';
			SET @ExecuteParam = '@sTypeID BIGINT, @sSortid INT OUTPUT';
			EXEC sp_executesql @ExecuteSQL, @ExecuteParam, @sTypeID, @sSortid=@sSortid OUTPUT

			SET @sSortid = ISNULL(@sSortid, 1);


			--�A�s�W���
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


