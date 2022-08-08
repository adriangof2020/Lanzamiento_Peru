/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT 
--      SUM([PlanTon]),ggg
--      SUM([RealTon]),
--      SUM([ProyPonderadaTon]),
--      SUM([PlanDol]),
--      SUM([RealDol]),
--      SUM([ProyPonderadaDol])
--  FROM [Lanzamientos].[dbo].[SELL_IN]



  --TRUNCATE TABLE [SELL_IN]
DECLARE @Date VARCHAR(7);
SELECT @Date = '08.2022'
PRINT @Date;

DELETE FROM  SELL_IN WHERE RIGHT(Fecha,7) = @Date;
  
BULK INSERT SELL_IN
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\SELL_IN.csv'
WITH (FIELDTERMINATOR=';', FIRSTROW=2, CODEPAGE='ACP')

DELETE FROM SELL_IN WHERE PlanTon = 0 AND RealTon = 0 AND ProyPonderadaTon = 0 AND PlanSol = 0
				          AND RealSol = 0  AND ProyPonderadaSol = 0;

UPDATE SELL_IN SET PlanTon = 0 WHERE  PlanTon IS NULL; 
UPDATE SELL_IN SET RealTon = 0 WHERE  RealTon IS NULL; 
UPDATE SELL_IN SET ProyPonderadaTon = 0 WHERE  ProyPonderadaTon IS NULL; 
UPDATE SELL_IN SET PlanSol = 0 WHERE  PlanSol IS NULL; 
UPDATE SELL_IN SET RealSol = 0 WHERE  RealSol IS NULL; 
UPDATE SELL_IN SET ProyPonderadaSol = 0 WHERE  ProyPonderadaSol IS NULL; 

UPDATE SELL_IN SET CodCategoria = TRIM(CodCategoria);
UPDATE SELL_IN SET Categoria = TRIM(Categoria);
UPDATE SELL_IN SET CodMarca = TRIM(CodMarca);
UPDATE SELL_IN SET Marca = TRIM(Marca);
UPDATE SELL_IN SET CodFamilia = TRIM(CodFamilia);
UPDATE SELL_IN SET Familia = TRIM(Familia);
UPDATE SELL_IN SET CodAlicorp = TRIM(CodAlicorp);
UPDATE SELL_IN SET Material = TRIM(Material);
UPDATE SELL_IN SET CodGrupoPrecios = TRIM(CodGrupoPrecios);
UPDATE SELL_IN SET GrupoPrecios = TRIM(GrupoPrecios);
UPDATE SELL_IN SET CodOficinaVentas = TRIM(CodOficinaVentas);
UPDATE SELL_IN SET OficinaVentas = TRIM(OficinaVentas);
UPDATE SELL_IN SET CodGrupoCondiciones = TRIM(CodGrupoCondiciones);
UPDATE SELL_IN SET GrupoCondiciones = TRIM(GrupoCondiciones);
UPDATE SELL_IN SET CodClienteActual = TRIM(CodClienteActual);
UPDATE SELL_IN SET ClienteActual = TRIM(ClienteActual);

   
IF OBJECT_ID(N'tempdb..#SELL_IN_STAGING') IS NOT NULL DROP TABLE #SELL_IN_STAGING;

SELECT A.Fecha, CONCAT(A.CodCategoria, ' - ', A.Categoria) Categoria, CONCAT(A.CodMarca, ' - ', A.Marca) Marca, CONCAT(A.CodFamilia, ' - ', A.Familia) Familia, CONCAT(A.CodAlicorp, ' - ', A.Material) Material,
	   CONCAT(A.CodGrupoPrecios, ' - ', A.GrupoPrecios) GrupoPrecios, CONCAT(A.CodOficinaVentas, ' - ', A.OficinaVentas) OficinaVentas, CONCAT(A.CodGrupoCondiciones, ' - ', A.GrupoCondiciones) GrupoCondiciones,
	   CONCAT(A.CodClienteActual, ' - ', A.ClienteActual) ClienteActual,
	   SUM(A.PlanTon) PlanTon, SUM(A.RealTon) RealTon, SUM(A.ProyPonderadaTon) ProyPonderadaTon, SUM(A.PlanSol) PlanSol, SUM(A.RealSol) RealSol, SUM(A.ProyPonderadaSol) ProyPonderadaSol
INTO #SELL_IN_STAGING
FROM SELL_IN A
WHERE RIGHT(Fecha,7) = @Date
GROUP BY A.Fecha, CONCAT(A.CodCategoria, ' - ', A.Categoria), CONCAT(A.CodMarca, ' - ', A.Marca), CONCAT(A.CodFamilia, ' - ', A.Familia), CONCAT(A.CodAlicorp, ' - ', A.Material),
	   CONCAT(A.CodGrupoPrecios, ' - ', A.GrupoPrecios), CONCAT(A.CodOficinaVentas, ' - ', A.OficinaVentas), CONCAT(A.CodGrupoCondiciones, ' - ', A.GrupoCondiciones),
	   CONCAT(A.CodClienteActual, ' - ', A.ClienteActual);
      
UPDATE #SELL_IN_STAGING SET Fecha = REPLACE(Fecha, '.','/');  


SET LANGUAGE SPANISH;

ALTER TABLE #SELL_IN_STAGING ALTER COLUMN Fecha DATE; 

SET LANGUAGE US_ENGLISH;

DECLARE @CountRows INT;
SELECT @CountRows = COUNT(*) FROM #SELL_IN_STAGING;
PRINT @CountRows;

DELETE FROM BASE_FINAL_SELL_IN WHERE YEAR(Fecha) = 2022 AND MONTH(Fecha) = 08;

INSERT INTO BASE_FINAL_SELL_IN
SELECT *
FROM (SELECT TOP (@CountRows) * FROM #SELL_IN_STAGING 
ORDER BY Fecha ASC) A;




      
      
      
      
