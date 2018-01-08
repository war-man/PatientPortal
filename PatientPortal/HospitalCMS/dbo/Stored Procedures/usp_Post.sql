﻿CREATE PROCEDURE [dbo].[usp_Post]
	@Id INT = 0,
	@LanguageCode CHAR(3) = 'vi',
	@WorkflowStateId TINYINT = 1,
	@CategoryId  TINYINT = 0
	--@PageIndex int, 
	--@NumberPerPage int, 
	--@TotalRecordCount int out
AS BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		DECLARE @return BIT = 1;

		IF @LanguageCode != '' AND @Id = 0
			IF @CategoryId = 0
				SELECT p.Id, t.Title, 
				c.Name AS CategoryName, 
				p.CategoryId,
				p.PublishDate,
				ws.Id AS WorkflowStateId,
				ws.Name AS WorkflowStateName,
				0 AS [Roles]
				FROM [dbo].Post p, [dbo].PostTrans t, [dbo].Category c, WorkflowState ws, [dbo].[Language] l--, PostRole r
				WHERE p.Id = t.PostId
				AND p.CategoryId = c.Id
				AND p.WorkflowStateId = ws.Id
				AND P.WorkflowStateId = @WorkflowStateId
				AND t.PostId = p.Id
				AND t.LanguageId = l.Id
				AND l.Code = @LanguageCode
			ELSE
				SELECT p.Id, t.Title, 
				c.Name AS CategoryName, 
				p.CategoryId,
				p.PublishDate,
				ws.Id AS WorkflowStateId,
				ws.Name AS WorkflowStateName,
				0 AS [Roles]
				FROM [dbo].Post p, [dbo].PostTrans t, [dbo].Category c, WorkflowState ws, PostRole r
				WHERE p.Id = t.PostId
				AND p.CategoryId = c.Id AND p.CategoryId = @CategoryId
				AND p.WorkflowStateId = ws.Id
				AND P.WorkflowStateId = @WorkflowStateId
				AND r.PostId = p.Id
		ELSE IF @languageCode = '' AND @Id > 0
			SELECT p.Id, 
			p.[Image],
			p.PublishDate,
			p.Author, 
			p.WorkflowStateId,
			p.CategoryId,
			p.[Status],
			p.CreatedBy,
			p.ModifiedBy,
			p.[Priority],
			p.ExpiredDate,

			ps.Title as TitleSEO, 
			ps.[Description] as DescriptionSEO, 
			ps.Canonical,
			ps.MetaRobotIndex,
			ps.MetaRobotFollow,
			ps.MetaRobotAdvanced,

			t.Title as TitleTrans, 
			c.Name as CategoryName, 
			t.[Description] as DescriptionTrans, 
			t.Detail,
			t.Tag

			FROM [dbo].Post p, [dbo].PostTrans t, [dbo].Category c, [dbo].PostSEO ps
			WHERE p.Id = t.PostId
			AND p.CategoryId = c.Id
			AND p.Id = ps.PostId
			--AND p.[Status] = 1
			AND p.Id = @Id
		ELSE
			SET @return = 0

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			BEGIN
				RETURN NULL
			END
	END CATCH
	SELECT @return
END