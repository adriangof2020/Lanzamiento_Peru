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

  DELETE FROM  SELL_IN WHERE RIGHT(Fecha,7) = '08.2022'
  
  BULK INSERT SELL_IN
  FROM 'C:\Proyectos\Peru\SELL_IN.csv'
  WITH (FIELDTERMINATOR=';', FIRSTROW=2, CODEPAGE='ACP')

  UPDATE SELL_IN SET [PlanTon] = 0 WHERE  [PlanTon] IS NULL; 
  UPDATE SELL_IN SET [RealTon] = 0 WHERE  [RealTon] IS NULL; 
   UPDATE SELL_IN SET [ProyPonderadaTon] = 0 WHERE  [ProyPonderadaTon] IS NULL; 
  UPDATE SELL_IN SET [PlanDol] = 0 WHERE  [PlanDol] IS NULL; 
    UPDATE SELL_IN SET [RealDol] = 0 WHERE  [RealDol] IS NULL; 
  UPDATE SELL_IN SET [ProyPonderadaDol] = 0 WHERE  [ProyPonderadaDol] IS NULL; 
 
   

