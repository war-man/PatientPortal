﻿CREATE PROC [dbo].[usp_Survey_Transaction]
(
	@Action CHAR(1) = 'I',
	@Id VARCHAR(128) = '',
	@Title NVARCHAR(150) = '',
	@Description NVARCHAR(MAX) = '',
	@Message NVARCHAR(300) = '',
	@IsBranding BIT = 1,
	@Logo VARCHAR(256) = '',
	@Url VARCHAR(256) = '',
	@IsSurveyInvite BIT = 0,
	@IsPublic BIT = 0,
	@IsActive BIT = 0
)
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	DECLARE @return INT = 0

	BEGIN TRY
		BEGIN TRAN;
			IF @Action = 'I' --INSERT
			BEGIN
				INSERT [dbo].[Survey] VALUES(@Id, @Title, @Description, @Message, @IsBranding, @Logo, @Url, @IsSurveyInvite, @IsPublic, @IsActive)

				SET @return = 1
			END

			IF @Action = 'U' --UPDATE
			BEGIN
				UPDATE [dbo].[Survey]
				SET [Title] = @Title, [Description] = @Description, [Message] = @Message, [IsBranding] = @IsBranding, [Logo] = @Logo, [Url] = @Url, [IsSurveyInvite] = @IsSurveyInvite, [IsPublic] = @IsPublic, [IsActive] = @IsActive
				WHERE [Id] = @Id  

				SET @return = 1
			END

			IF @Action = 'D' --DELETE
			BEGIN
				BEGIN
					--Xóa câu trả lời của từng câu hỏi.
					DELETE FROM [dbo].[SurveyAnswers] WHERE [QuestionId] IN (SELECT q.[Id] FROM [dbo].[SurveyQuestions] q WHERE q.[SurveyId] = @Id)

					--Xóa từng câu hỏi của khảo sát.
					DELETE FROM [dbo].[SurveyQuestions] WHERE [SurveyId] = @Id
					
					--Xóa khảo sát
					DELETE FROM [dbo].[Survey] WHERE [Id] = @Id

					SET @return = 1
				END
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
	SELECT @return;
END