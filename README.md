mssql-storedprocedure
=====================

My Microsoft SQL Server stored procedure scripts in common use.

***

procDataSort
---
��ƥ洫�Ƨ� (�D���ެ� sID, �ƧǭȬ� sSortid)


@tablename VARCHAR(50),		--��W

@inputId BIGINT,		--��J����

@inputAct CHAR(1),		--�ʧ@�A�O�W���ΤU��

@sTypeID BIGINT = 0		--��������

***

procTypeSort
---
���O�洫�Ƨ� (�D���ެ� sID, �ƧǭȬ� sSortid)


@tablename varchar(50),		--��W

@inputId INT,			--���ޭ�

@inputAct CHAR(1)		--�ʧ@�A�O�W���ΤU��


***

procInsertNews
---
�s�W��� (�H�s�W�s�D��Ƭ���) (�D���ެ� sID, �ƧǭȬ� sSortid)


@tablename varchar(50) = NULL,		--��W

@sID BIGINT = NULL,			--����

@insertMode BIT = 0,			--�Ҧ� (1:�s�W)

@sTitle NVARCHAR(200),			--���D

@sContent NVARCHAR(MAX),		--����

@sTypeID INT,				--��������

@sVisible BIT,				--�O�_���

@sTop BIT,				--�O�_�m��

@sStartEnable BIT,			--�O�_�}�ҤW�U�[���

@sStartDate SMALLDATETIME,		--�W�[��

@sEndDate SMALLDATETIME,		--�U�[��

@sReturnID BIGINT OUTPUT		--��^����


***

procTypeInsert
---
�s�W������� (�D���ެ� sID, �ƧǭȬ� sSortid)


@tablename varchar(20),			--��W

@sCaption nvarchar(100),		--�W��

@sVisible tinyint			--�O�_���


***

procSortidRefresh
---
�� sSortid ���ƮɡA�����檺���s�Ƨǧ@�~ (�D���ެ� sID, �ƧǭȬ� sSortid)


@tablename varchar(50)			--��W

