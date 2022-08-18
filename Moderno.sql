USE Lanzamientos;
--"14-08-2022"

DECLARE @Date VARCHAR(7);
SELECT @Date = '08/2022';
PRINT @Date;

DELETE FROM  MODERNO WHERE RIGHT(Fecha,7) = @Date;

BULK INSERT MODERNO
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\MODERNO.csv'
WITH (FIELDTERMINATOR=';', FIRSTROW=2, CODEPAGE='ACP');

UPDATE MODERNO SET Importe = REPLACE(Importe, ',', '')


--set language US_ENGLISH

--UPDATE MODERNO SET Fecha = REPLACE(Fecha, '"', '')
--UPDATE MODERNO SET Cadena = REPLACE(Cadena, '"', '')
--UPDATE MODERNO SET Cliente = REPLACE(Cliente, '"', '')
--UPDATE MODERNO SET Departamento = REPLACE(Departamento, '"', '')
--UPDATE MODERNO SET Categoria = REPLACE(Categoria, '"', '')
--UPDATE MODERNO SET Familia = REPLACE(Familia, '"', '')
--UPDATE MODERNO SET CodAlicorp = REPLACE(CodAlicorp, '"', '')
--UPDATE MODERNO SET Material = REPLACE(Material, '"', '')
--UPDATE MODERNO SET RealTon = REPLACE(RealTon, '"', '')
--UPDATE MODERNO SET Importe = REPLACE(Importe, '"', '')


UPDATE MODERNO SET Fecha = TRIM(Fecha);
UPDATE MODERNO SET Cadena = TRIM(Cadena);
UPDATE MODERNO SET Cliente = TRIM(Cliente);
UPDATE MODERNO SET Departamento = TRIM(Departamento);
UPDATE MODERNO SET Categoria = TRIM(Categoria);
UPDATE MODERNO SET Familia = TRIM(Familia);
UPDATE MODERNO SET CodAlicorp =TRIM(CodAlicorp);
UPDATE MODERNO SET Material = TRIM(Material);
--UPDATE MODERNO SET Importe = TRIM(Importe);

UPDATE MODERNO SET Importe = '0' WHERE  Importe IS NULL; 
UPDATE MODERNO SET RealTon = 0 WHERE  RealTon IS NULL; 

DELETE FROM MODERNO  WHERE RealTon = 0 and Importe = '0';

IF OBJECT_ID(N'tempdb..#MODERNO_STAGING') IS NOT NULL DROP TABLE #MODERNO_STAGING;

SELECT A.Fecha, A.Cadena, A.Cliente, A.Departamento, A.Categoria, A.Familia, CONCAT(A.CodAlicorp, ' - ', A.Material) Material,
	   SUM(CONVERT(FLOAT,A.Importe))/1000 Importe, SUM(A.RealTon) RealTon
INTO #MODERNO_STAGING
FROM MODERNO A
WHERE RIGHT(Fecha,7) = @Date
GROUP BY A.Fecha, A.Cadena, A.Cliente, A.Departamento, A.Categoria, A.Familia, CONCAT(A.CodAlicorp, ' - ', A.Material) ;

SET LANGUAGE SPANISH;

ALTER TABLE #MODERNO_STAGING ALTER COLUMN Fecha DATE; 

SET LANGUAGE US_ENGLISH;

--SELECT * FROM #MODERNO_STAGING

DECLARE @CountRows INT;
SELECT @CountRows = COUNT(*) FROM #MODERNO_STAGING;
PRINT @CountRows;

DELETE FROM BASE_FINAL_MODERNO WHERE YEAR(Fecha) = 2022 AND MONTH(Fecha) = 08;

INSERT INTO BASE_FINAL_MODERNO
SELECT *
FROM (SELECT TOP (@CountRows) * FROM #MODERNO_STAGING 
ORDER BY Fecha ASC) A;