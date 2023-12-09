--ACTIVAMOS NUESTRA BASE DE DATOS
USE LamsCruises
GO
--CONTROLAMOS LA EXISTENCIA DEL PROCEDIMIENTO ALMACENADO
DROP PROC IF EXISTS Backup_Cursor
GO

--CREAMOS NUESTRO PROCEDIMIENTO ALMACENADO Y EMPEZAMOS DECLARANDO LAS VARIABLES QUE VAMOS A UTILIZAR
CREATE OR ALTER PROC Backup_Cursor
AS
BEGIN
    DECLARE @NombreDB VARCHAR(50)
    DECLARE @Ruta VARCHAR(256)
    DECLARE @Carpeta VARCHAR(256)
    DECLARE @Fecha VARCHAR(50)

    -- ESPECIFICAMOS LA RUTA DONDE QUEREMOS GUARDAR LOS BACKUPS
    SET @Ruta = 'C:\Backup_Cursores'

    -- Generamos una cadena de fecha sin caracteres especiales con el formato de fecha que queremos, en este caso 112
    SET @Fecha = REPLACE(CONVERT(VARCHAR(50), GETDATE(), 112), ':', '')

    -- DECLARAMOS EL CURSOR
	-- LA CONSULTA SELECT VA A VERIFICAR EN LA TABLA SYS.DATABSES CUALES SON LAS BASES DE DATOS DEL SISTEMA
    DECLARE BD_Cursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
    SELECT name
    FROM sys.databases
	--LAS QUE SE ENCUENTREN EN LA TABLA SYS.DATABASES SON LAS QUE LE HARÁ EL BACKUP
    WHERE name IN ('master', 'LamsCruises', 'NORTHWIND', 'AdventureWorks2022', 'Ejemplo', 'pubs')

    -- PROCEDEMOS A ABRIR EL CURSOR
    OPEN BD_Cursor
    FETCH NEXT FROM BD_Cursor INTO @NombreDB

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construimos la ruta completa del archivo de respaldo
        SET @Carpeta = @Ruta + '\' + @NombreDB + '_' + @Fecha + '.BAK'

        -- Realizamos el backup de la base de datos
        BACKUP DATABASE @NombreDB TO DISK = @Carpeta WITH INIT

        -- Recuperamos la siguiente fila del cursor
        FETCH NEXT FROM BD_Cursor INTO @NombreDB
    END

    -- CERRAMOS Y DESASOCIAMOS EL CURSOR
    CLOSE BD_Cursor
    DEALLOCATE BD_Cursor
END
GO


EXECUTE Backup_Cursor
go