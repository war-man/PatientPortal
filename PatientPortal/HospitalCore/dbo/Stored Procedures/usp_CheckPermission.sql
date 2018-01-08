﻿CREATE PROCEDURE [dbo].[usp_CheckPermission]
	@UserId NVARCHAR(128) = '',
	@OperationKey VARCHAR(70) = '',
	@ResourceKey VARCHAR(70) = '',
	@DefaultRoleInitial NVARCHAR(256) = ''
AS
BEGIN
   SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	DECLARE @Permission NVARCHAR(128)
	DECLARE @PermissionName NVARCHAR(30)
	SET @PermissionName = RTRIM(@ResourceKey) + '.' + RTRIM(@OperationKey)

	--CHECK ADMIN
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[Users] WHERE [Id] = @UserId AND  [IsAdmin] = 1)
	BEGIN
		PRINT 'OKEY ADMIN'
		SELECT 1
		RETURN(1)
	END
	--CHECK USER IN ROLES
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[UserRole] a LEFT JOIN [dbo].[Role] b ON a.[RoleId] = b.[Id]
	WHERE [UserId] = @UserId AND b.[Name] = @DefaultRoleInitial)
	BEGIN
		PRINT 'OKEY ADMIN 2'
		SELECT 1
		RETURN(1)
	END

	-- CHECK PERMISSION
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[UserRole] WHERE [UserId] = @UserId AND [RoleId] IN (
	SELECT [RoleId] FROM [dbo].[PermissionRoles] a LEFT JOIN [dbo].[Permissions] b
	ON a.[PermissionId] = b.[Id] WHERE b.[Name] = @PermissionName))
	BEGIN
		PRINT 'OKEY ALLOWED'
		SELECT 1
		RETURN(1)
	END

	SELECT 0
	RETURN(0)
END