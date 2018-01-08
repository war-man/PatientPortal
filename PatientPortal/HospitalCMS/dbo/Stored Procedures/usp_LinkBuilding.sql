﻿CREATE PROC [dbo].[usp_LinkBuilding]
	@Id SMALLINT
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRY
		IF @Id > 0
			SELECT * FROM [dbo].[LinkBuilding]
			WHERE [Id] = @Id
			order by [Id]
		ELSE
			SELECT * FROM [dbo].[LinkBuilding]
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
		BEGIN
			RETURN NULL
		END
	END CATCH
END