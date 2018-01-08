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
PRINT N'Altering [dbo].[usp_Post]...';


GO
ALTER PROCEDURE [dbo].[usp_Post]
	@postId INT,
	@languageId TINYINT
AS BEGIN
	BEGIN TRY
		IF @postId <> 0 AND @languageId <> 0
			SELECT * FROM [dbo].Post
		ELSE
			SELECT * FROM [dbo].Post WHERE [Id] = @postId
			SELECT * FROM [dbo].PostSEO WHERE [PostId] = @postId
			SELECT * FROM [dbo].PostTrans WHERE [PostId] = @postId AND [LanguageId] = @languageId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			BEGIN
				RETURN NULL
			END
	END CATCH
END
GO
PRINT N'Altering [dbo].[usp_Post_Transaction]...';


GO
ALTER PROCEDURE [dbo].[usp_Post_Transaction]
	@Action CHAR(1) = 'I',
	@id INT,
	@date DATE,
	@image VARCHAR(256),
	@author NVARCHAR(50),
	@workflowStateId TINYINT,
	@categoryId TINYINT,
	@status TINYINT,
	@createdDate VARCHAR(20),
	@createdBy INT,
	@modifiedDate VARCHAR(20),
	@modifiedBy INT,
	-- parameter PostSEO
	@postId INT,
	@title_SEO NVARCHAR(71),
	@decription_SEO NVARCHAR(160),
	@canonical VARCHAR(256),
	@breadcrumbsTitle NVARCHAR(71),
	@metaRobotIndex TINYINT,
	@metaRobotFollow TINYINT,
	@metaRobotAdvanced TINYINT,
	-- parameter PostTrans
	@languageId TINYINT,
	@title_Trans NVARCHAR(256),
	@decription_Trans NVARCHAR(1000),
	@detail NVARCHAR(MAX),
	@tag NVARCHAR(60),
	-- parameter PostStateHistory
	@idPostStateHis INT,
	@userId INT,
	@note NVARCHAR(500)
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	DECLARE @return bit = 1
	BEGIN TRY
		BEGIN TRAN
			IF @Action = 'I' 
			BEGIN
				-- INSERT POST
				SET IDENTITY_INSERT [dbo].Post ON
				INSERT INTO [dbo].Post
				VALUES(@date,@image,@author,@workflowStateId,@categoryId,@status,@createdDate,
				@createdBy,@modifiedDate,@modifiedBy)
				SET IDENTITY_INSERT [dbo].Post OFF

				-- INSERT POST_SEO
				SET @postId = SCOPE_IDENTITY()
				INSERT INTO [dbo].PostSEO
				VALUES(@postId,@title_SEO,@decription_SEO,@canonical,@breadcrumbsTitle,@metaRobotIndex,
				@metaRobotFollow,@metaRobotAdvanced)

				-- INSERT POST_TRANS
				INSERT INTO [dbo].PostTrans
				VALUES(@postId,@languageId,@title_Trans,@decription_Trans,@detail,@tag)

				-- INSERT INTO PostStateHistory
				SET IDENTITY_INSERT [dbo].PostStateHistory ON
				INSERT INTO PostStateHistory
				VALUES(@postId,@workflowStateId,@userId,@note,@createdDate)
				SET IDENTITY_INSERT [dbo].PostStateHistory OFF
			END				
			IF @Action = 'U' 
			BEGIN
				-- UPDATE POST
				UPDATE [dbo].Post
				SET [Date] = @date, [Image] = @image, [Author] = @author, [WorkflowStateId] = @workflowStateId,
				[CategoryId] = @categoryId, [Status] = @status, [CreatedDate] = @createdDate, [CreatedBy] = @createdBy,
				[ModifiedDate] = @modifiedDate, [ModifiedBy] = @modifiedBy
				WHERE [Id] = @postId

				-- UPDATE POST_SEO
				UPDATE [dbo].PostSEO
				SET [PostId] = @postId, [Title] = @title_SEO, [Description] = @decription_SEO,
				[Canonical] = @canonical, [BreadcrumbsTitle] = @breadcrumbsTitle, [MetaRobotIndex] = @metaRobotIndex,
				[MetaRobotFollow] = @metaRobotFollow, [MetaRobotAdvanced] = @metaRobotAdvanced
				WHERE [PostId] = @postId

				-- UPDATE POST_TRANS
				UPDATE [dbo].PostTrans
				SET [PostId] = @postId, [LanguageId] = @languageId, [Title] = @title_Trans,
				[Description] = @decription_Trans, [Detail] = @detail, [Tag] = @tag
				WHERE [PostId] = @postId AND [LanguageId] = @languageId

				-- UPDATE POST_STATE_HISTORY
				UPDATE [dbo].PostStateHistory
				SET [PostId] = @postId, [WorkflowStateId] = @workflowStateId, [UserId] = @userId,
				[Note] = @note, [CreatedDate] = @createdDate
				WHERE [Id] = @idPostStateHis AND [PostId] = @postId
			END
			IF @Action = 'D' 
			BEGIN
				-- DELETE POST_SEO
				DELETE FROM [dbo].PostSEO
				WHERE [PostId] = @postId

				-- DELTE POST_TRANS
				DELETE FROM [dbo].PostTrans
				WHERE [PostId] = @postId

				-- DELETE POST
				DELETE FROM [dbo].Post 
				WHERE [Id] = @id
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
PRINT N'Creating [dbo].[usp_PostStateHistory]...';


GO
CREATE PROCEDURE [dbo].[usp_PostStateHistory]
AS BEGIN
	BEGIN TRY
		SELECT * FROM PostStateHistory
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			BEGIN
				RETURN NULL
			END
	END CATCH
END
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
GO

GO
PRINT N'Update complete.';


GO