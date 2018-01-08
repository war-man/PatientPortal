﻿CREATE PROC [dbo].[usp_Appointment_Transaction]
(
	@Action CHAR(1) = 'I',
	@Id INT = 1,--Appointment
	@Date DATE = '',
	@Time int = 8,
	@PhysicianId NVARCHAR(128) = '',
	@PatientId NVARCHAR(128) = '',
	@Symptom NVARCHAR(300) = '',
	@AppointmentNo SMALLINT = 0,
	@PatientName NVARCHAR(50) = '',
	@PatientAddress NVARCHAR(150) = '',
	@PatientEmail VARCHAR(256) = '',
	@PatientPhone VARCHAR(20) = '',
	@PatientGender TINYINT = 1,
	@PatientDoB DATE = '',
	@Status TINYINT = 1
)
AS BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	DECLARE @return INT = 0
	DECLARE @CreatedDate VARCHAR(20)
	DECLARE @ModifiedDate VARCHAR(20)

	BEGIN TRY
		BEGIN TRAN;

			SET @ModifiedDate = [dbo].[ufnGetDate]()

			IF @Action = 'I' --INSERT
			BEGIN
				
				SET @CreatedDate = @ModifiedDate

				INSERT [dbo].[Appointment]
				VALUES(@PhysicianId, @PatientId, @Symptom, @CreatedDate, @ModifiedDate, @PatientId)

				SET @return = SCOPE_IDENTITY()

				INSERT [dbo].[AppointmentCollection] 
				VALUES(@Id, @Date, @Time, @AppointmentNo, @PatientName, @PatientAddress, @PatientEmail, @PatientPhone, @PatientGender, @PatientDoB, @Status)
				
			END

			IF @Action = 'U' --UPDATE
			BEGIN
				--STATUS: 0 - Just Created/Pending, 1 - Approved, 2 - Canceled
				IF EXISTS( SELECT TOP 1 1 FROM [dbo].[Appointment] WHERE [Id] = @Id)
				BEGIN
					UPDATE [dbo].[Appointment]
					SET [PhysicianId] = @PhysicianId, [PatientId] = @PatientId, [Symptom] = @Symptom, [ModifiedDate] = @ModifiedDate
					WHERE [Id] = @Id  

					UPDATE [dbo].[AppointmentCollection]
					SET [AppointmentNo] = @AppointmentNo, [PatientName] = @PatientName, [PatientEmail] = @PatientEmail,
					[PatientAddress] = @PatientAddress, [PatientPhone] = @PatientPhone ,[PatientGender] = @PatientGender, [PatientDoB] =  @PatientDoB, [Status] = @Status
					WHERE [Id] = @Id  

					SET @return = @Id
				END
				ELSE
					SET @return = 0
			END

			IF @Action = 'D' --DELETE
			BEGIN
				IF EXISTS( SELECT TOP 1 1 FROM [dbo].[Appointment] WHERE [Id] = @Id)
				BEGIN
					DELETE FROM [dbo].[AppointmentCollection]
					WHERE [Id] = @Id

					DELETE FROM [dbo].[Appointment]
					WHERE [Id] = @Id

					SET @return = @Id
				END
				ELSE
					SET @return = 0
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