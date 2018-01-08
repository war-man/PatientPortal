﻿/*
Deployment script for HospitalCMS

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "HospitalCMS"
:setvar DefaultFilePrefix "HospitalCMS"
:setvar DefaultDataPath "D:\MSSQL\DATA\"
:setvar DefaultLogPath "D:\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO

GO
/*
The column [dbo].[CMS].[IsSendEmailWF] on table [dbo].[CMS] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.
*/

IF EXISTS (select top 1 1 from [dbo].[CMS])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
/*
The column [dbo].[Post].[Type] on table [dbo].[Post] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.
*/

IF EXISTS (select top 1 1 from [dbo].[Post])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Rename refactoring operation with key f87a464a-608c-431e-a4c7-f4b092a93cd0 is skipped, element [dbo].[Advertise].[IsUsed] (SqlSimpleColumn) will not be renamed to Handler';


GO
PRINT N'Rename refactoring operation with key 018a1622-59c2-47d9-a142-6425933c8b53 is skipped, element [dbo].[Advertise].[IsUsed] (SqlSimpleColumn) will not be renamed to Resouce';


GO
PRINT N'Altering [dbo].[CMS]...';


GO
ALTER TABLE [dbo].[CMS]
    ADD [IsSendEmailWF] BIT NOT NULL;


GO
PRINT N'Altering [dbo].[Post]...';


GO
ALTER TABLE [dbo].[Post]
    ADD [Type] TINYINT NOT NULL;


GO
PRINT N'Creating [dbo].[Advertise]...';


GO
CREATE TABLE [dbo].[Advertise] (
    [Id]          SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (150) NOT NULL,
    [Description] NVARCHAR (250) NOT NULL,
    [StartDate]   DATE           NOT NULL,
    [EndDate]     DATE           NOT NULL,
    [Position]    TINYINT        NOT NULL,
    [Handler]     VARCHAR (256)  NOT NULL,
    [Resouce]     VARCHAR (256)  NOT NULL,
    [IsUsed]      BIT            NOT NULL,
    [Type]        TINYINT        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Altering [dbo].[usp_Post_Transaction]...';


GO
ALTER PROCEDURE [dbo].[usp_Post_Transaction]
	@Action CHAR(1) = 'I',
	@Id INT,
	@Image VARCHAR(256),
	@Author NVARCHAR(50),
	@WorkflowStateId TINYINT = 1,
	@CategoryId TINYINT,
	@Status TINYINT = 1,
	@CreatedBy INT,
	@ModifiedBy INT,
	@Priority TINYINT,
	@ExpiredDate DATE,
	@Type TINYINT = 1,
	-- PostSEO
	@PostId INT,
	@TitleSEO NVARCHAR(71),
	@DescriptionSEO NVARCHAR(160),
	@Canonical VARCHAR(256),
	@BreadcrumbsTitle NVARCHAR(71),
	@MetaRobotIndex TINYINT,
	@MetaRobotFollow TINYINT,
	@MetaRobotAdvanced TINYINT,
	-- PostTrans
	@LanguageId TINYINT,
	@TitleTrans NVARCHAR(256),
	@DescriptionTrans NVARCHAR(1000),
	@Detail NVARCHAR(MAX),
	@Tag NVARCHAR(60),
	-- PostStateHistory
	@UserId INT,
	@Note NVARCHAR(500) 
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	DECLARE @return INT = 0
	DECLARE @Date SMALLDATETIME, @PresentDate VARCHAR(20)
	SET @Date = GETDATE()
	SET @PresentDate = [dbo].[ufnGetDate]()

	BEGIN TRY
		BEGIN TRAN
			IF @Action = 'I' 
			BEGIN
				-- Post Table
				INSERT INTO [dbo].[Post]
				VALUES(@Date, @Image, @Author, @WorkflowStateId, @CategoryId, @Status, @PresentDate,
				@CreatedBy, @PresentDate, @ModifiedBy, @Priority, @ExpiredDate, @Type)

				-- PostSEO Table
				SET @PostId = SCOPE_IDENTITY()
				INSERT INTO [dbo].[PostSEO]
				VALUES(@PostId, @TitleSEO, @DescriptionSEO, @Canonical, @BreadcrumbsTitle, @MetaRobotIndex,
				@MetaRobotFollow, @MetaRobotAdvanced)

				-- PostTrans Table
				INSERT INTO [dbo].[PostTrans]
				VALUES(@PostId, @LanguageId, @TitleTrans, @DescriptionTrans, @Detail, @Tag)

				-- PostStateHistory Table
				INSERT INTO [dbo].[PostStateHistory]
				VALUES(@PostId, @WorkflowStateId, @UserId, @Note, @PresentDate)

				--SET RETURN ID
				SET @return = @PostId
			END				
			IF @Action = 'U' 
			BEGIN
				
				IF((SELECT WorkflowStateId FROM [dbo].Post WHERE Id = @Id) = 1)
				BEGIN
					-- Post Table
					UPDATE [dbo].[Post]
					SET [PublishDate] = @Date, [Image] = @Image, [Author] = @Author,
					[CategoryId] = @CategoryId, [Status] = @Status,
					[ModifiedDate] = @PresentDate, [ModifiedBy] = @ModifiedBy,
					[Priority] = @Priority, [ExpiredDate] = @ExpiredDate, [Type] = @Type
					WHERE [Id] = @Id

					-- PostSEO Table
					UPDATE [dbo].[PostSEO]
					SET [PostId] = @Id, [Title] = @TitleSEO, [Description] = @DescriptionSEO,
					[Canonical] = @Canonical, [BreadcrumbsTitle] = @BreadcrumbsTitle, [MetaRobotIndex] = @MetaRobotIndex,
					[MetaRobotFollow] = @MetaRobotFollow, [MetaRobotAdvanced] = @MetaRobotAdvanced
					WHERE [PostId] = @Id

					-- PostTrans Table
					UPDATE [dbo].[PostTrans]
					SET [LanguageId] = @LanguageId, [Title] = @TitleTrans,
					[Description] = @DescriptionTrans, [Detail] = @Detail, [Tag] = @Tag
					WHERE [PostId] = @Id AND [LanguageId] = @LanguageId

					-- PostStateHistory Table
					IF NOT EXISTS( SELECT TOP 1 1 FROM [dbo].[PostStateHistory] WITH(INDEX(IdxPostStateHistoryPost)) WHERE [PostId] = @Id AND [WorkflowStateId] = @WorkflowStateId )
					BEGIN
						INSERT INTO [dbo].[PostStateHistory]
						VALUES(@Id, @WorkflowStateId, @UserId, @Note, @PresentDate)
					END

					SET @return = @Id
				END
				ELSE
					SET @return = 0
			END
			IF @Action = 'D' 
			BEGIN
				IF((SELECT WorkflowStateId FROM [dbo].Post WHERE Id = @Id) = 1)
				BEGIN
					--  PostSEO Table
					DELETE FROM [dbo].[PostSEO]
					WHERE [PostId] = @Id

					-- PostTrans Table
					DELETE FROM [dbo].[PostTrans]
					WHERE [PostId] = @Id

					-- PostStateHistory
					DELETE FROM [dbo].[PostStateHistory]
					WHERE [PostId] = @Id

					-- Post Table
					DELETE FROM [dbo].[Post]
					WHERE [Id] = @Id

					SET @return = @Id
				END
				ELSE
					SET @return = 0
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			BEGIN
				ROLLBACK TRAN
				SET @return = 0
			END
	END CATCH
	SELECT @return
END
GO
PRINT N'Altering [dbo].[usp_spa_Slider]...';


GO
ALTER PROC [dbo].[usp_spa_Slider]
	@Id TINYINT
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRY
		IF @Id > 0
			SELECT * FROM [dbo].[Slider]
			WHERE [Id] = @Id
		ELSE
			SELECT * FROM [dbo].[Slider] WHERE ([IsUsed] = 1 OR [ExpiredDate] >= GETDATE()) AND [Image] <> '' 
			ORDER BY [Id]
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
		BEGIN
			RETURN NULL
		END
	END CATCH
END
GO
PRINT N'Creating [dbo].[usp_Advertise]...';


GO
CREATE PROCEDURE [dbo].[usp_Advertise]
	@Id TINYINT
AS
	IF(@Id > 0)
	BEGIN
		SELECT * FROM [dbo].[Advertise]
		WHERE [Id] = @Id
	END
	ELSE
	BEGIN
		SELECT * FROM [dbo].[Advertise]
		ORDER BY [Id]
	END
RETURN 0
GO
PRINT N'Creating [dbo].[usp_Advertise_CheckExistName]...';


GO
CREATE PROCEDURE [dbo].[usp_Advertise_CheckExistName]
	@Name  NVARCHAR(50),
	@Id TINYINT
AS
BEGIN
	DECLARE @return BIT = 0

	print @Id
	IF(@Id = 0)
		IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[Advertise] WHERE [Name] = @Name))
			SET @return = 1
	ELSE
		IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[Advertise] WHERE [Name] = @Name and Id <> @Id))
			SET @return = 1
	SELECT @return
END
GO
PRINT N'Creating [dbo].[usp_Advertise_Transaction]...';


GO
CREATE PROCEDURE [dbo].[usp_Advertise_Transaction]
	@Action CHAR(1) = 'I',
	@Id SMALLINT,
	@Name NVARCHAR, 
    @Description NVARCHAR = '', 
    @StartDate DATE, 
    @EndDate DATE, 
    @Position TINYINT = 0, 
    @Handler VARCHAR(256) = '', 
    @Resouce VARCHAR(256) = '',
	@Type tinyint = 0, 
    @IsUsed BIT  = 1
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	DECLARE @return bit = 1
	BEGIN TRY
		BEGIN TRAN;
		
		IF @Action = 'I' --INSERT
		BEGIN
			INSERT [dbo].[Advertise](Name, [Description], [StartDate], [EndDate], [Position], [Handler], [Resouce], [IsUsed], [Type])
			VALUES(@Name, @Description, @StartDate, @EndDate, @Position, @Handler, @Resouce, @IsUsed, @Type)
		END

		IF @Action = 'U' --UPDATE
		BEGIN
			UPDATE [dbo].[Advertise]
			SET [Name] = @Name, [Description] = @Description, [StartDate] = @StartDate, [EndDate]= @EndDate, Position = @Position, Handler=@Handler, Resouce = @Resouce, IsUsed = @IsUsed, [Type] = @Type
			WHERE [Id] = @Id
		END

		IF @Action = 'D' --DELETE
		BEGIN
			DELETE FROM [dbo].[Advertise]
			WHERE [Id] = @Id
		END

		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
		BEGIN
			ROLLBACK TRAN;
			SET  @return = 0
		END
	END CATCH
	SELECT @return
	
END
GO
PRINT N'Creating [dbo].[usp_spa_Advertise]...';


GO
CREATE PROCEDURE [dbo].[usp_spa_Advertise]
	@Id TINYINT
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRY
		IF @Id > 0
			SELECT * FROM [dbo].[Advertise]
			WHERE [Id] = @Id
		ELSE
			SELECT * FROM [dbo].[Advertise]
			ORDER BY [Id]
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
		BEGIN
			RETURN NULL
		END
	END CATCH
END
GO
PRINT N'Refreshing [dbo].[usp_Configuration]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Configuration]';


GO
PRINT N'Refreshing [dbo].[usp_Configuration_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Configuration_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_spa_CMSConfig]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_spa_CMSConfig]';


GO
PRINT N'Refreshing [dbo].[usp_ApprovePost_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_ApprovePost_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_Category_CheckHasChildOrPost]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Category_CheckHasChildOrPost]';


GO
PRINT N'Refreshing [dbo].[usp_Category_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Category_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_Language_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Language_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_Post]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_Post]';


GO
PRINT N'Refreshing [dbo].[usp_PublishPost_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_PublishPost_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_spa_Post]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_spa_Post]';


GO
PRINT N'Refreshing [dbo].[usp_spa_Post_ById]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_spa_Post_ById]';


GO
PRINT N'Refreshing [dbo].[usp_WorkflowNavigation_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_WorkflowNavigation_Transaction]';


GO
PRINT N'Refreshing [dbo].[usp_WorkflowState_Transaction]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[usp_WorkflowState_Transaction]';


GO
-- Refactoring step to update target server with deployed transaction logs
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'f87a464a-608c-431e-a4c7-f4b092a93cd0')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('f87a464a-608c-431e-a4c7-f4b092a93cd0')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '018a1622-59c2-47d9-a142-6425933c8b53')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('018a1622-59c2-47d9-a142-6425933c8b53')

GO

GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[Workflow] WHERE Name = N'Workflow post')
BEGIN
	DECLARE @WorkflowId TINYINT = 0
	DECLARE @WorkflowStateId TINYINT = 0
	DECLARE @NextWorkflowStateId TINYINT = 0
	---------------
	INSERT INTO [dbo].Workflow
	VALUES(N'Workflow post')
	---------
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].WorkflowState WHERE Name = N'Đang soạn thảo')
		BEGIN
			SET @WorkflowId = SCOPE_IDENTITY()
			INSERT INTO [dbo].WorkflowState
			VALUES(N'Đang soạn thảo', @WorkflowId, 1, 1)

			SET @WorkflowStateId = SCOPE_IDENTITY()
		END
	---------------
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].WorkflowState WHERE Name = N'Đã duyệt')
		BEGIN
			INSERT INTO [dbo].WorkflowState
			VALUES(N'Đã duyệt', @WorkflowId, 1, 0)

			SET @WorkflowStateId = SCOPE_IDENTITY()
		END
	--------------
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].WorkflowState WHERE Name = N'Đã đăng bài')
		BEGIN
			INSERT INTO [dbo].WorkflowState
			VALUES(N'Đã đăng bài', @WorkflowId, 1, 0)

			SET @NextWorkflowStateId = SCOPE_IDENTITY()
		END
	----------------------
	IF @WorkflowStateId > 0 AND @NextWorkflowStateId > 0
		BEGIN
			INSERT INTO [dbo].WorkflowNavigation
			VALUES(@WorkflowStateId, @NextWorkflowStateId)
		END
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Trang chủ')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Trang chủ', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Dịch vụ')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Dịch vụ', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Chuyên khoa')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Chuyên khoa', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Giới thiệu')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Giới thiệu', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Tin tức')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Tin tức', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Category WHERE Name = N'Liên hệ')
	BEGIN
		INSERT INTO [dbo].Category
		VALUES(N'Liên hệ', '', '', 1, 0)	
	END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].Language WHERE Code = 'vi')
	BEGIN
		INSERT INTO [dbo].Language
		VALUES('vi', 'VietNam')	
	END
GO

GO
PRINT N'Update complete.';


GO