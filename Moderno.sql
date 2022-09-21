USE Lanzamientos;
--"14-08-2022"

DECLARE @Date VARCHAR(7);
SELECT @Date = '09/2022';
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




SET LANGUAGE SPANISH;

IF OBJECT_ID(N'tempdb..#MODERNO_STAGING') IS NOT NULL DROP TABLE #MODERNO_STAGING;

SELECT CONVERT(DATE, A.Fecha, 103) Fecha, A.Cadena, B.ClienteHomologado, A.Departamento, A.Local, CONCAT(C.CodMarca, '-', C.Marca) Marca,
	   CONCAT(C.CodCategoria, '-', C.Categoria) Categoria, CONCAT(C.CodFamilia, '-', C.Familia) Familia, CONCAT(A.CodAlicorp, ' - ', C.Material) Material,
	   SUM(CONVERT(FLOAT,A.Importe))/1000 RealSol, SUM(A.RealTon) RealTon, 0 PlanTon, 0 PlanSol
INTO #MODERNO_STAGING
FROM MODERNO A
	LEFT JOIN MAESTRO_CLIENTE B ON A.Cliente = B.Cliente
	LEFT JOIN MAESTRO_ALICORP_MODERNO C ON A.CodAlicorp = C.CodAlicorp
--WHERE RIGHT(A.Fecha,7) = @Date
GROUP BY CONVERT(DATE, A.Fecha, 103), A.Cadena, B.ClienteHomologado, A.Departamento, A.Local, CONCAT(C.CodMarca, '-', C.Marca),
	     CONCAT(C.CodCategoria, '-', C.Categoria), CONCAT(C.CodFamilia, '-', C.Familia), CONCAT(A.CodAlicorp, ' - ', C.Material) ;

ALTER TABLE #MODERNO_STAGING ALTER COLUMN PlanTon FLOAT;
ALTER TABLE #MODERNO_STAGING ALTER COLUMN PlanSol FLOAT;

IF OBJECT_ID(N'tempdb..#MODERNO_STAGING2') IS NOT NULL DROP TABLE #MODERNO_STAGING2;

SELECT CONVERT(DATE, A.Fecha, 103) Fecha, 'SIN DATOS PLAN' Cadena, B.ClienteHomologado, 'SIN DATOS PLAN' Departamento,  'SIN DATOS PLAN' Local, CONCAT(C.CodMarca, '-', C.Marca) Marca,
	   CONCAT(C.CodCategoria, '-', C.Categoria) Categoria, CONCAT(C.CodFamilia, '-', C.Familia) Familia, CONCAT(A.CodAlicorp, ' - ', C.Material) Material,
	   0 RealSol, 0 RealTon, SUM(A.PlanTon) PlanTon, SUM(A.PlanSol) PlanSol INTO #MODERNO_STAGING2
FROM PLAN_MODERNO A
	LEFT JOIN MAESTRO_CLIENTE B ON A.Cliente = B.Cliente
	LEFT JOIN MAESTRO_ALICORP_MODERNO C ON A.CodAlicorp = C.CodAlicorp
--WHERE RIGHT(A.Fecha,7) = @Date
GROUP BY CONVERT(DATE, A.Fecha, 103), B.ClienteHomologado, CONCAT(C.CodMarca, '-', C.Marca),
	     CONCAT(C.CodCategoria, '-', C.Categoria), CONCAT(C.CodFamilia, '-', C.Familia), CONCAT(A.CodAlicorp, ' - ', C.Material) ;

SET LANGUAGE US_ENGLISH;

INSERT INTO #MODERNO_STAGING
SELECT *
FROM #MODERNO_STAGING2


--DECLARE @CountRows INT;
--SELECT @CountRows = COUNT(*) FROM #MODERNO_STAGING;
--PRINT @CountRows;


INSERT INTO BASE_FINAL_MODERNO
SELECT *
FROM
--(SELECT TOP (@CountRows) * FROM
#MODERNO_STAGING 
--ORDER BY Fecha ASC) A;