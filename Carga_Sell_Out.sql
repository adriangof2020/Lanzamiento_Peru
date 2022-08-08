DECLARE @Date VARCHAR(7);
SELECT @Date = '08.2022'
PRINT @Date;

DELETE FROM  SELL_OUT_MAYOR WHERE RIGHT(Fecha,7) = @Date;
  
BULK INSERT SELL_OUT_MAYOR
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\SELL_OUT_MAYOR.csv'
WITH (FIELDTERMINATOR=';', FIRSTROW=2, CODEPAGE='ACP')

DELETE FROM SELL_OUT_MAYOR WHERE PlanTon = 0 AND RealTon = 0 AND ProyPonderadaTon = 0 AND PlanSol = 0
							     AND RealSol = 0 AND ProyPonderadaSol = 0;

UPDATE SELL_OUT_MAYOR SET TipoDex = 'Mayorista' WHERE TipoDex IS NULL;

UPDATE SELL_OUT_MAYOR SET PlanTon = 0 WHERE  PlanTon IS NULL; 
UPDATE SELL_OUT_MAYOR SET RealTon = 0 WHERE  RealTon IS NULL; 
UPDATE SELL_OUT_MAYOR SET ProyPonderadaTon = 0 WHERE  ProyPonderadaTon IS NULL; 
UPDATE SELL_OUT_MAYOR SET PlanSol = 0 WHERE  PlanSol IS NULL; 
UPDATE SELL_OUT_MAYOR SET RealSol = 0 WHERE  RealSol IS NULL; 
UPDATE SELL_OUT_MAYOR SET ProyPonderadaSol = 0 WHERE  ProyPonderadaSol IS NULL; 

UPDATE SELL_OUT_MAYOR SET CodCategoria = TRIM(CodCategoria);
UPDATE SELL_OUT_MAYOR SET Categoria = TRIM(Categoria);
UPDATE SELL_OUT_MAYOR SET CodMarca = TRIM(CodMarca);
UPDATE SELL_OUT_MAYOR SET Marca = TRIM(Marca);
UPDATE SELL_OUT_MAYOR SET CodFamilia = TRIM(CodFamilia);
UPDATE SELL_OUT_MAYOR SET Familia = TRIM(Familia);
UPDATE SELL_OUT_MAYOR SET CodAlicorp = TRIM(CodAlicorp);
UPDATE SELL_OUT_MAYOR SET Material = TRIM(Material);
UPDATE SELL_OUT_MAYOR SET CodGrupoPrecios = TRIM(CodGrupoPrecios);
UPDATE SELL_OUT_MAYOR SET GrupoPrecios = TRIM(GrupoPrecios);
UPDATE SELL_OUT_MAYOR SET CodOficinaVentas = TRIM(CodOficinaVentas);
UPDATE SELL_OUT_MAYOR SET OficinaVentas = TRIM(OficinaVentas);
UPDATE SELL_OUT_MAYOR SET CodGrupoCondiciones = TRIM(CodGrupoCondiciones);
UPDATE SELL_OUT_MAYOR SET GrupoCondiciones = TRIM(GrupoCondiciones);
UPDATE SELL_OUT_MAYOR SET CodClienteActual = TRIM(CodClienteActual);
UPDATE SELL_OUT_MAYOR SET ClienteActual = TRIM(ClienteActual);
UPDATE SELL_OUT_MAYOR SET CodClientedex = TRIM(CodClientedex);
UPDATE SELL_OUT_MAYOR SET Clientedex = TRIM(CodClientedex);

--Minorista
--TRUNCATE TABLE SELL_OUT_MINOR
DELETE FROM  SELL_OUT_MINOR WHERE RIGHT(Fecha,7) = @Date;
  
BULK INSERT SELL_OUT_MINOR
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\SELL_OUT_MINOR.csv'
WITH (FIELDTERMINATOR=';', FIRSTROW=2, CODEPAGE='ACP')

DELETE FROM SELL_OUT_MINOR WHERE PlanTon = 0 AND RealTon = 0 AND ProyPonderadaTon = 0 AND PlanSol = 0
							     AND RealSol = 0 AND ProyPonderadaSol = 0;

UPDATE SELL_OUT_MINOR SET TipoDex = 'Minorista' WHERE TipoDex IS NULL;

UPDATE SELL_OUT_MINOR SET PlanTon = 0 WHERE  PlanTon IS NULL; 
UPDATE SELL_OUT_MINOR SET RealTon = 0 WHERE  RealTon IS NULL; 
UPDATE SELL_OUT_MINOR SET ProyPonderadaTon = 0 WHERE  ProyPonderadaTon IS NULL; 
UPDATE SELL_OUT_MINOR SET PlanSol = 0 WHERE  PlanSol IS NULL; 
UPDATE SELL_OUT_MINOR SET RealSol = 0 WHERE  RealSol IS NULL; 
UPDATE SELL_OUT_MINOR SET ProyPonderadaSol = 0 WHERE  ProyPonderadaSol IS NULL; 

UPDATE SELL_OUT_MINOR SET CodCategoria = TRIM(CodCategoria);
UPDATE SELL_OUT_MINOR SET Categoria = TRIM(Categoria);
UPDATE SELL_OUT_MINOR SET CodMarca = TRIM(CodMarca);
UPDATE SELL_OUT_MINOR SET Marca = TRIM(Marca);
UPDATE SELL_OUT_MINOR SET CodFamilia = TRIM(CodFamilia);
UPDATE SELL_OUT_MINOR SET Familia = TRIM(Familia);
UPDATE SELL_OUT_MINOR SET CodAlicorp = TRIM(CodAlicorp);
UPDATE SELL_OUT_MINOR SET Material = TRIM(Material);
UPDATE SELL_OUT_MINOR SET CodGrupoPrecios = TRIM(CodGrupoPrecios);
UPDATE SELL_OUT_MINOR SET GrupoPrecios = TRIM(GrupoPrecios);
UPDATE SELL_OUT_MINOR SET CodOficinaVentas = TRIM(CodOficinaVentas);
UPDATE SELL_OUT_MINOR SET OficinaVentas = TRIM(OficinaVentas);
UPDATE SELL_OUT_MINOR SET CodGrupoCondiciones = TRIM(CodGrupoCondiciones);
UPDATE SELL_OUT_MINOR SET GrupoCondiciones = TRIM(GrupoCondiciones);
UPDATE SELL_OUT_MINOR SET CodClienteActual = TRIM(CodClienteActual);
UPDATE SELL_OUT_MINOR SET ClienteActual = TRIM(ClienteActual);
UPDATE SELL_OUT_MINOR SET CodClientedex = TRIM(CodClientedex);
UPDATE SELL_OUT_MINOR SET Clientedex = TRIM(CodClientedex);


   
IF OBJECT_ID(N'tempdb..#SELL_OUT_STAGING') IS NOT NULL DROP TABLE #SELL_OUT_STAGING;

SELECT A.Fecha, A.TipoDex, CONCAT(A.CodCategoria, ' - ', A.Categoria) Categoria, CONCAT(A.CodMarca, ' - ', A.Marca) Marca, CONCAT(A.CodFamilia, ' - ', A.Familia) Familia, CONCAT(A.CodAlicorp, ' - ', A.Material) Material,
	   CONCAT(A.CodGrupoPrecios, ' - ', A.GrupoPrecios) GrupoPrecios, CONCAT(A.CodOficinaVentas, ' - ', A.OficinaVentas) OficinaVentas, CONCAT(A.CodGrupoCondiciones, ' - ', A.GrupoCondiciones) GrupoCondiciones,
	   CONCAT(A.CodClienteActual, ' - ', A.ClienteActual) ClienteActual, CONCAT(A.CodClientedex, ' - ', A.Clientedex) Clientedex,
	   SUM(A.PlanTon) PlanTon, SUM(A.RealTon) RealTon, SUM(A.ProyPonderadaTon) ProyPonderadaTon, SUM(A.PlanSol) PlanSol, SUM(A.RealSol) RealSol, SUM(A.ProyPonderadaSol) ProyPonderadaSol
INTO #SELL_OUT_STAGING
FROM SELL_OUT_MAYOR A
WHERE RIGHT(Fecha,7) = @Date
GROUP BY A.Fecha, A.TipoDex, CONCAT(A.CodCategoria, ' - ', A.Categoria), CONCAT(A.CodMarca, ' - ', A.Marca), CONCAT(A.CodFamilia, ' - ', A.Familia), CONCAT(A.CodAlicorp, ' - ', A.Material),
	   CONCAT(A.CodGrupoPrecios, ' - ', A.GrupoPrecios), CONCAT(A.CodOficinaVentas, ' - ', A.OficinaVentas), CONCAT(A.CodGrupoCondiciones, ' - ', A.GrupoCondiciones),
	   CONCAT(A.CodClienteActual, ' - ', A.ClienteActual), CONCAT(A.CodClientedex, ' - ', A.Clientedex);

INSERT INTO #SELL_OUT_STAGING
SELECT B.Fecha, B.TipoDex, CONCAT(B.CodCategoria, ' - ', B.Categoria) Categoria, CONCAT(B.CodMarca, ' - ', B.Marca) Marca, CONCAT(B.CodFamilia, ' - ', B.Familia) Familia, CONCAT(B.CodAlicorp, ' - ', B.Material) Material,
	   CONCAT(B.CodGrupoPrecios, ' - ', B.GrupoPrecios) GrupoPrecios, CONCAT(B.CodOficinaVentas, ' - ', B.OficinaVentas) OficinaVentas, CONCAT(B.CodGrupoCondiciones, ' - ', B.GrupoCondiciones) GrupoCondiciones,
	   CONCAT(B.CodClienteActual, ' - ', B.ClienteActual) ClienteActual, CONCAT(B.CodClientedex, ' - ', B.Clientedex) Clientedex,
	   SUM(B.PlanTon) PlanTon, SUM(B.RealTon) RealTon, SUM(B.ProyPonderadaTon) ProyPonderadaTon, SUM(B.PlanSol) PlanSol, SUM(B.RealSol) RealSol, SUM(B.ProyPonderadaSol) ProyPonderadaSol
FROM SELL_OUT_MINOR B
WHERE RIGHT(Fecha,7) = @Date
GROUP BY B.Fecha, B.TipoDex, CONCAT(B.CodCategoria, ' - ', B.Categoria), CONCAT(B.CodMarca, ' - ', B.Marca), CONCAT(B.CodFamilia, ' - ', B.Familia), CONCAT(B.CodAlicorp, ' - ', B.Material),
	   CONCAT(B.CodGrupoPrecios, ' - ', B.GrupoPrecios), CONCAT(B.CodOficinaVentas, ' - ', B.OficinaVentas), CONCAT(B.CodGrupoCondiciones, ' - ', B.GrupoCondiciones),
	   CONCAT(B.CodClienteActual, ' - ', B.ClienteActual), CONCAT(B.CodClientedex, ' - ', B.Clientedex);
      
UPDATE #SELL_OUT_STAGING SET Fecha = REPLACE(Fecha, '.','/');  
--SELECT * FROM #SELL_OUT_STAGING WHERE TipoDex = 'Mayorista'

SET LANGUAGE SPANISH;

ALTER TABLE #SELL_OUT_STAGING ALTER COLUMN Fecha DATE; 

SET LANGUAGE US_ENGLISH;

DECLARE @CountRows1 INT;
SELECT @CountRows1 = COUNT(*) FROM #SELL_OUT_STAGING;
PRINT @CountRows1;

DELETE FROM BASE_FINAL_SELL_OUT WHERE YEAR(Fecha) = 2022 AND MONTH(Fecha) = 08;

INSERT INTO BASE_FINAL_SELL_OUT
SELECT *
FROM (SELECT TOP (@CountRows1) * FROM #SELL_OUT_STAGING 
ORDER BY Fecha ASC) A;