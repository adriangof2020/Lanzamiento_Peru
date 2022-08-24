	
--AVANCE SELL OUT EVA by Cesar Cajas -- No copiar Sin Autorizacion >:( 

--SELECT * FROM SplitFinal where Split =1

--CREATE DATABASE EVA_PERU
--GO
USE EVA_PERU
GO
SET DATEFORMAT DMY
GO
SET LANGUAGE SPANISH;
GO

-- ACTUALIZAR UNA VEZ AL MES
			-- Feriados
			-- Base Split (Toneladas)
			-- Base Split 2 (Soles)
			-- Maestro Territori0
			-- Base Plan Sell In
			-- Base Mes Anterior y Mes año Anterior

-- ACTUALIZAR DIARIAMENTE
----------------------------------------------------------------------------------------------------------------
-----------------------------------------¡¡¡¡¡¡VALIDADORES!!!!!-----------------------------------------------
------------------¡¡¡¡¡¡CORRER UNA VEZ EL QUERY PARA REALIZAR VALIDACIONES!!!!!-------------------
----------------------------------------------------------------------------------------------------------------
/*
-- VALIDADOR SPLIT (Encuentra si hay un Distribuidor + Material Que no tiene un Split Asignado

SELECT CodDistribuidor, CodMaterial FROM SplitMensual WHERE Split IS NULL

-- VALIDADOR SPLIT, Determina si la Suma de los Split de todos los Vendedores por distribuidor es Diferente a 1

SELECT CodDistribuidor, CodMaterial, SUM(Split) Debe_Sumar_1 FROM SplitMensual GROUP BY CodDistribuidor, CodMaterial HAVING SUM(Split) < 0.99999999 AND SUM(Split) > 1.00000001
*/

----------------------------------------------------------------------------------------------------------------
-----------------------------------------¡¡¡¡¡¡IMPORTANTE!!!!!------------------------------------------------
-------------ASEGURARSE QUE SE HAYA ACTUALIZADO LOS [Eva_Peru].[dbo].[Feriados]----------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[Feriados]   --Indica los feriados a considerar como dias no laborables
	BULK INSERT [Eva_Peru].[dbo].[Feriados]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Maestros\Feriados.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')
	-- SELECT * FROM Feriados

----------------------------------------------------------------------------------------------------------------
----------------------------------------MAESTRO TERRITORIOS---------------------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[MaestroTerritorio] -- LLave CodDistribuidor-CodTerritorio para asignar Of.Ventas, Grp Precios, Grp Vendedores, etc.
	BULK INSERT [Eva_Peru].[dbo].[MaestroTerritorio]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Maestros\Maestro Territorio.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

	UPDATE MaestroTerritorio
	SET CodDistribuidor = RIGHT(CodDistribuidor,10)
----------------------------------------------------------------------------------------------------------------
--------------------------INGRESANDO LA BASE SELL OUT MES ACTUAL----------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[BaseInicialSellOut]			-- Base del mes actual-Mes en curso
	BULK INSERT [Eva_Peru].[dbo].[BaseInicialSellOut]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\Mes Actual.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

----------------------------------------------------------------------------------------------------------------
-------------------------INGRESANDO LA BASE SELL OUT MES ANTERIOR---------------------------------
----------------------------------------------------------------------------------------------------------------
	BULK INSERT [Eva_Peru].[dbo].[BaseInicialSellOut]					--Base del mes anterior
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\Mes Anterior.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

----------------------------------------------------------------------------------------------------------------
----------------------INGRESANDO LA BASE SELL OUT MES AÑO ANTERIOR------------------------------
----------------------------------------------------------------------------------------------------------------
	BULK INSERT [Eva_Peru].[dbo].[BaseInicialSellOut]					--Base del mes en curso del año anterior (<por el momento se considera 2 meses anteriores)
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\Mes Año Anterior.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

	-- SELECT * FROM BaseSOFinal order by PlanSoles DESC

	UPDATE BaseInicialSellOut														-- El importe se divide en Miles 
	SET VentaSolesSO = VentaSolesSO/1000

----------------------------------------------------------------------------------------------------------------
---------------------------- ELIMINANDO FILAS NO HOMOLOGADAS-------------------------------------
----------------------------------------------------------------------------------------------------------------
DELETE [Eva_Peru].[dbo].[BaseInicialSellOut]
WHERE CodMaterial IS NULL or CodMaterial = 0
----------------------------------------------------------------------------------------------------------------
-------------------------- CONSERVANDO SOLO NEGOCIO CORE Y VALUE--------------------------------
----------------------------------------------------------------------------------------------------------------
DELETE [Eva_Peru].[dbo].[BaseInicialSellOut]
WHERE Negocio not in ('Core','Value')

----------------------------------------------------------------------------------------------------------------
-------------------------------INGRESANDO LA BASE SPLIT TONELADAS-----------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[BaseSplit]
	BULK INSERT [Eva_Peru].[dbo].[BaseSplit]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\Base Split Ton.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

	UPDATE BaseSplit
	SET CodDistribuidor = RIGHT(CodDistribuidor,10)

----------------------------------------------------------------------------------------------------------------
-------------------------------INGRESANDO LA BASE PRE SPLIT HISTORICO-----------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[PreSplitHistorico]
	BULK INSERT [Eva_Peru].[dbo].[PreSplitHistorico]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\PreSplitHistorico.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

	DELETE [Eva_Peru].[dbo].[PreSplitHistorico] WHERE CodMaterial = '0'
----------------------------------------------------------------------------------------------------------------
---------------------------INGRESANDO MAESTRO DUEÑO DE MARCA---------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[MaestroDueñoMarca]
	BULK INSERT [Eva_Peru].[dbo].[MaestroDueñoMarca]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Maestros\MaestroDM.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

----------------------------------------------------------------------------------------------------------------
-------------------------------INGRESANDO LA BASE PLAN SELL IN------------------------------------
----------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [Eva_Peru].[dbo].[BasePlanSell_In]
	BULK INSERT [Eva_Peru].[dbo].[BasePlanSell_In]
	FROM 'D:\CODIS\Avance de Ventas Distribuidores No Exclusivos\Bases\BasePlanSellIn.csv'
	WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')



--SELECT DISTINCT CodDistribuidor, Distribuidor FROM BaseInicialSellOut
--SELECT DISTINCT CodDistribuidor, Distribuidor FROM MaestroTerritorio
----------------------------------------------------------------------------------------------------------------
-------CORRE AL INICIO DE CADA MES PARA CREAR TABLA [Eva_Peru].[dbo].[Fechas] DEL MES--------
-------------ASEGURARSE QUE SE HAYA ACTUALIZADO LOS [Eva_Peru].[dbo].[Feriados-----------------
----------------------------------------------------------------------------------------------------------------

DECLARE @DiaReporte DATE = GetDate();																						-- Dia en el que se Ejecuta el Query
DECLARE @DiaCierre DATE = (SELECT MAX(Fecha) FROM BaseInicialSellOut)								-- Ultimo Dia cargado en la base Inicial
--DECLARE @DiaCierre DATE = '31/03/2022'						
DECLARE @FinMes DATE = EOMONTH(@DiaCierre,0);																	-- Ultimo Dia del Mes
SET @DiaCierre = IIF(@DiaCierre = @FinMes OR @FinMes < GETDATE(), @FinMes, DATEADD(DAY,-1,GETDATE()))

DECLARE @InicioMes DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinMes), 0)	;			-- Primer Dia del Mes
DECLARE @Cant INT = 0;																												-- Numero incremental +1 Para el Loop WHILE
DECLARE @SumDia INT = 0;																											-- Suma de los Dias Habiles Acumulados en el Mes
DECLARE @SumSemana INT = 0;																									-- Suma de los Dias Habiles Acumulados en el el rango de Semana
DECLARE @CambioSemana VARCHAR(50);																					-- Agrupacion de Semana
DECLARE @Mes INT = MONTH(@DiaCierre);
DECLARE @Año INT = YEAR(@DiaCierre);
DECLARE @Dia INT = DAY(@DiaCierre);

IF NOT EXISTS (SELECT * FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha = @DiaCierre)				-- Solo INgresa al ser un nuevo mes, si la fecha ya existe recien entra a la condicional
BEGIN

			DELETE Fechas WHERE Año < @Año -1 

			WHILE @Cant < DAY(@FinMes)			-- Loop Recorre desde el dia uno hasta el Ultimo dia del mes
				BEGIN
							DECLARE @Fecha DATE = DATEADD(DAY,@Cant,@InicioMes);			-- Va asignando a la variable @Fecha el Dia a dia hasta completar el mes
							INSERT INTO [Eva_Peru].[dbo].[Fechas]
							(Fecha
							,Dia
							,Mes
							,Periodo
							,Semana_Año
							,Año
							,DiaLab)
							VALUES (
							@Fecha 
							,DAY(@Fecha)
							,MONTH(@Fecha)
							,CONCAT(UPPER(LEFT(FORMAT(@Fecha, 'MMMyy'), 1)), RIGHT(FORMAT(@Fecha, 'MMMyy'), 5))
							,CONCAT('Semana.', IIF(LEN(DATEPART(WK, @Fecha)) = 2, DATEPART(WK, @Fecha) , 	CONCAT(0,DATEPART(WK, @Fecha))	))
							,YEAR(@Fecha)
							,IIF( DATEPART(DW,@Fecha) = 7 OR EXISTS (SELECT * FROM [Eva_Peru].[dbo].[Feriados] WHERE Feriado = @Fecha) , 0 ,1)); -- Si es Domingo o se encuentra en la Tabla "[Eva_Peru].[dbo].[Feriados]" le asigna 0 a la columna Dia Habil si es un dia Util le asigna 1
					SET @Cant = @Cant + 1;			-- Incremental Loop +1
				END;
			
			UPDATE [Eva_Peru].[dbo].[Fechas]					-- Asigna el rangode semana segun la columna dia
				SET Semana = CASE
				WHEN Dia >= 1 AND Dia <= 7			THEN 'Del 1 al 7'
				WHEN Dia >= 8 AND Dia <= 14			THEN 'Del 8 al 14'
				WHEN Dia >= 15 AND Dia <= 21		THEN 'Del 15 al 21'
				WHEN Dia >= 22 AND Dia <= 31		THEN 'Del 22 al 31'
				END
				WHERE Año = YEAR(@DiaCierre) AND Mes = MONTH(@DiaCierre);		-- Solo afecta al mes en curso

				SET @Cant = 0;											-- Incremental Loop
				SET @SumDia = 0;										-- Sum Acumulada de dias acumulado en el mes
				SET @SumSemana = 0;								-- Sum Acumulada de dias acumulado en el rango de semanas
				SET @CambioSemana = 'Del 1 al 7';			-- Rango de semana asignado al primer dia del mes

				WHILE @Cant < DAY(@FinMes)					-- Loop Recorre desde el dia uno hasta el Ultimo dia del mes
				BEGIN
									SET		@Fecha =  DATEADD(DAY,@Cant,@InicioMes);																											-- Va asignando a la variable @Fecha el Dia a dia hasta completar el mes
									SET		@SumDia = @SumDia +  (SELECT DiaLab FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha =@Fecha)						-- Va acumulando Los dias habiles en el mes +1 si es un dia Habil +0 si es un dia Feriado o domingo (Se apoya en la Columna "DiaLab")
									SET		@SumSemana = @SumSemana +  (SELECT DiaLab FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha =@Fecha)		-- Va acumulando Los dias habiles en el rango de semana +1 si es un dia Habil +0 si es un dia Feriado o domingo (Se apoya en la Columna "DiaLab")
									IF @CambioSemana <> (SELECT Semana FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha =@Fecha)									-- Condicional si detecta un cambio de rango de semana
										BEGIN
												SET @CambioSemana = (SELECT Semana FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha =@Fecha);						-- Al detectar un cambio de semana la variable se le asigna el nuevo rango de semana
												SET @SumSemana = (SELECT DiaLab FROM [Eva_Peru].[dbo].[Fechas] WHERE Fecha =@Fecha);							-- Al detetar un cambio se semana peride el acumulado y se le asigna +1 o +0 si ese dia es dia laborable o dia 
										END;
								UPDATE [Eva_Peru].[dbo].[Fechas]
									SET		DiasLabAcum = @SumDia,																							-- Se asigna los dias Acumulados del mes
												DiasLabSemana = @SumSemana																				-- Se asgna los dias Acumulados del rango de semana
									WHERE Año = YEAR(@Fecha) AND Mes = MONTH(@Fecha) AND Dia = DAY(@Fecha)
								SET @Cant = @Cant + 1;
				END;
END;

DECLARE @Semana VARCHAR(50) = (SELECT Semana FROM Fechas WHERE Fecha = @DiaCierre);
DECLARE @DiaHabMesActual INT = (SELECT DiasLabAcum FROM Fechas WHERE Fecha = @DiaCierre);

UPDATE Fechas
	SET FactorMes = CASE
		WHEN A.Mes = @Mes		AND		A.Año = @Año AND Dia <= @Dia		THEN COALESCE(CAST(1/NULLIF(CAST(@DiaHabMesActual AS FLOAT),0) AS FLOAT),0)					-- Cuando se encuentra en el mes actual y el dia es menor igual al dia de cierre, el Factor es igual a 1 entre los dias habiles a la fecha
		WHEN A.Mes = @Mes		AND		A.Año = @Año AND Dia > @Dia		THEN 0																																				-- Cuando se encuentra en el mes actual y el dia es mayo al dia de cierre, el Factor es igual a 0
		ELSE			 COALESCE( CAST(1/ NULLIF( CAST ((SELECT MAX(DiasLabAcum) FROM Fechas B WHERE A.Mes = B.Mes AND A.Año = B.Año) AS FLOAT),0) AS FLOAT),0)			-- Cuando se encuentra en meeses anteriores el Factor es igual a 1 entre los dias habiles totales del mes
		END
	FROM Fechas A;

UPDATE Fechas
	SET FactorSemana = CASE
		WHEN @DiaCierre = @FinMes THEN COALESCE( CAST(1/ NULLIF( CAST ((SELECT MAX(DiasLabSemana) FROM Fechas B WHERE A.Mes = B.Mes AND A.Año = B.Año AND A.Semana = B.Semana) AS FLOAT),0) AS FLOAT),0)					-- Cuando es Fin de mes (Reporte de Cierre) el Factor es igual a 1 entre los dias habiles totales de la semana
		WHEN Dia > @Dia THEN 0																																																																																			-- Cuando es mayor al dia de cierre el Factor es igual a cero
		WHEN Dia <= @Dia	AND Semana = @Semana			THEN	COALESCE(CAST(1/NULLIF(CAST((SELECT DiasLabSemana FROM Fechas B WHERE B.Dia = @Dia AND A.Mes = B.Mes AND A.Año = B.Año)  AS FLOAT),0) AS FLOAT),0)		-- Cuando el dia es menor al dia de cierre y se encuentra en el rango de la semana de cierre el factor es igual a 1 entre los dias habiles trancurrides del rango de la semana
		ELSE		COALESCE( CAST(1/ NULLIF( CAST ((SELECT MAX(DiasLabSemana) FROM Fechas B WHERE A.Mes = B.Mes AND A.Año = B.Año AND A.Semana = B.Semana) AS FLOAT),0) AS FLOAT),0)																	-- Cuando el dia es menor al dia de cierre y se encuentra en un rango de semana menor a la semana de cierre el factor es igual a 1 entre los dias habiles totales del rango de la semana
		END
		FROM Fechas A;

UPDATE Fechas																																																																			
	SET FactorDiasHab = CASE
		WHEN @DiaCierre = @FinMes THEN COALESCE(CAST(1/NULLIF(CAST(  (SELECT MAX(DiasLabAcum) FROM Fechas WHERE  Mes = A.Mes AND Año = A.Año) AS FLOAT),0) AS FLOAT),0)					-- Cuando es fin de mes el Factor es igual a 1 entre los dias habiles totales 
		WHEN  Dia <= @Dia		THEN COALESCE(CAST(1/NULLIF(CAST(  (SELECT DiasLabAcum FROM Fechas WHERE Dia = @Dia AND Mes = A.Mes AND Año = A.Año) AS FLOAT),0) AS FLOAT),0)			-- Cuando no es Fin de mes y el dia es menor al dia de cierre el factor es igual a 1 entre los dias habiles a la fecha
		WHEN  Dia > @Dia		THEN 0																																																																		-- Cuando el dia es mayor al dia de cierre el Factor es igual a 0
		END
	FROM Fechas A;

---------------------------------------------------------------------------------------------------------------
---------------------------GENERANDO EL SPLIT MENSUAL TONELADAS---------------------------------
---------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE PreSplit
INSERT INTO PreSplit
SELECT  DISTINCT A.[CodDistribuidor], CONCAT(DM.CodDM, '-', A.[CodCategoria]) CodCategoriaDM, A.[CodFamilia], A.[CodMaterial], B.[CodTerritorio] FROM 
[EVA_PERU].[dbo].[BaseInicialSellOut] A 
LEFT JOIN MaestroDueñoMarca DM ON A.CodMarca = DM.CodMarca
LEFT JOIN (SELECT DISTINCT [CodDistribuidor], [CodTerritorio] FROM BaseSplit) B 
ON A.CodDistribuidor = B.CodDistribuidor;

INSERT INTO PreSplit
SELECT DISTINCT A.[CodDistribuidor], A.[CodCategoriaDM], A.[CodFamilia], A.[CodMaterial], B.[CodTerritorio] FROM PreSplitHistorico A
LEFT JOIN (SELECT DISTINCT [CodDistribuidor], [CodTerritorio] FROM BaseSplit) B 
ON A.CodDistribuidor = B.CodDistribuidor																													
WHERE A.[CodDistribuidor]+A.[CodCategoriaDM]+A.[CodFamilia]+A.[CodMaterial] NOT IN (SELECT DISTINCT [CodDistribuidor]+[CodCategoriaDM]+[CodFamilia]+[CodMaterial] FROM PreSplit)

-- select * from presplit
--- EXPLICACION DEL SPLIT AL FINAL
TRUNCATE TABLE SplitFinal
INSERT INTO SplitFinal
SELECT  
DISTINCT 
A.CodDistribuidor,  
A.CodCategoriaDM, 
A.CodFamilia,
A.CodMaterial, 
ISNULL(IIF(M.SplitTon is NULL  AND F.SplitTon is NULL  AND C.SplitTon is NULL ,NULL,B.CodTerritorio),'S/A') Territorio,  
ISNULL(ISNULL(ISNULL(M.SplitTon,F.SplitTon),C.SplitTon),1) Split
FROM PreSplit A
LEFT JOIN (SELECT DISTINCT [CodDistribuidor], [CodTerritorio] FROM BaseSplit) B ON A.CodDistribuidor = B.CodDistribuidor 
LEFT JOIN SplitMaterial M ON A.CodDistribuidor = M.CodDistribuidor AND A.CodCategoriaDM = M.CodCategoriaDM AND A.CodFamilia = M.CodFamilia AND A.CodMaterial = M.CodMaterial AND B.CodTerritorio = M.CodTerritorio 
LEFT JOIN SplitFamilia F ON  A.CodDistribuidor = F.CodDistribuidor AND A.CodCategoriaDM = F.CodCategoriaDM AND A.CodFamilia = F.CodFamilia AND A.CodMaterial = F.CodMaterial AND B.CodTerritorio = F.CodTerritorio
LEFT JOIN SplitCategoria C ON  A.CodDistribuidor = C.CodDistribuidor  AND A.CodCategoriaDM = C.CodCategoriaDM AND A.CodFamilia = C.CodFamilia AND A.CodMaterial = C.CodMaterial AND B.CodTerritorio = C.CodTerritorio 
ORDER BY A.CodDistribuidor, A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, Territorio;

---- EN CASO EN LA BASE SELL IN UN DISTRIBUIDOR SE ASIGNE A UN SOLO TERRITORIO Y TENGA SPLIT SIN AGINAR, SE BRINDA TODO LA VENTA  A ESE TERRITORIO
UPDATE SplitFinal
SET CodTerritorio = CASE
											WHEN		SF.CodTerritorio <> 'S/A'		
													THEN	SF.CodTerritorio
											WHEN		SF.CodDistribuidor IN (SELECT T.CodDistribuidor FROM MaestroTerritorio T GROUP BY  T.CodDistribuidor HAVING Count(T.CodTerritorio) = 1)		
													THEN (SELECT T2.CodTerritorio FROM MaestroTerritorio T2 WHERE T2.CodDistribuidor = SF.CodDistribuidor)
											ELSE			'S/A'
								END
FROM SplitFinal SF;

--- EN CASO HAYA VENTAS DE UN MISMO MATERIAL DOS TERRITORIOS SE TOMA EN CONSIDERACION EL QUE TIENE MAYOR VENTA

--SELECT  CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial, MAX(Split) SplitMax FROM SplitFinal  WHERE Split <> 0 AND Split <> 1 GROUP BY CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial

TRUNCATE TABLE SplitAuxiliar
INSERT INTO SplitAuxiliar
	SELECT  B.CodDistribuidor, B.CodCategoriaDM, B.CodFamilia, B.CodMaterial, A.CodTerritorio
				FROM SplitFinal A,  
							(SELECT  CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial, MAX(Split) SplitMax FROM SplitFinal  WHERE Split <> 0 AND Split <> 1 GROUP BY CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial   ) B
										WHERE A.CodDistribuidor = B.CodDistribuidor AND A.CodCategoriaDM = B.CodCategoriaDM AND A.CodFamilia = B.CodFamilia AND A.CodMaterial = B.CodMaterial AND A.Split = B.SplitMax;

UPDATE SplitFinal
		SET Split = 0
		WHERE Split <> 0 AND Split <> 1;

UPDATE SplitFinal
	SET Split = 1
	FROM SplitFinal A, (SELECT DISTINCT * FROM SplitAuxiliar) B
	WHERE A.CodDistribuidor = B.CodDistribuidor AND A.CodCategoriaDM = B.CodCategoriaDM AND A.CodFamilia = B.CodFamilia AND A.CodMaterial = B.CodMaterial AND A.CodTerritorio = B.CodTerritorio ;

	--SELECT * FROM SplitAuxiliar
	--SELECT * FROM SplitFinal WHERE Split <> 0 AND CodMaterial = '9350357'

DECLARE @DiaHabMesTotal	 INT = (SELECT DiasLabAcum FROM Fechas WHERE Fecha = @FinMes)
DECLARE @DiasFaltantes	INT = IIF(@DiaHabMesTotal	-	@DiaHabMesActual = 0, 1, @DiaHabMesTotal	-	@DiaHabMesActual )
DECLARE @DiaMA DATE = DATEADD(MONTH,-1,@InicioMes)
DECLARE @DiaMAA	DATE = DATEADD(MONTH,-2,@InicioMes)		

TRUNCATE TABLE BaseSOFinal
INSERT INTO BaseSOFinal
SELECT 
A.Fecha																																																															Fecha
,F.Año																																																																Año
,F.Mes																																																																MES
,F.Periodo																																																															Periodo
,F.Semana_Año																																																												SemanaAño
,F.Semana																																																														SemanaRango
,F.Dia																																																																Dia
,A.Plataforma																																																													Plataforma
,A.Negocio																																																														Negocio
,A.Categoria																																																														Categoria
,A.Familia																																																															Familia
, A.Marca																																																															Marca
,CONCAT(A.CodMaterial, ' - ', A.Material)																																																		Material
,DM.DM																																																															DueñoMarca
,A.Agrupacion																																																													Agrupacion
,CONCAT(A.CodDistribuidor, ' - ', A.Distribuidor)																																															Distribuidor
,CONCAT(S.CodTerritorio,' - ',IIF(S.CodTerritorio <> 'S/A',T.Territorio,'Sin Asignar'))																																		Territorio
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpCond1,' - ',T.GrpCond1), 'S/A - Sin Asignar')																														GrupoCondiciones
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpPrecios,' - ',T.GrpPrecios), 'S/A - Sin Asignar')																														GrupoPrecios
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodZnVentas,' - ',T.ZnVentas), 'S/A - Sin Asignar')																															ZonaVentas
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodOfVentas,' - ',T.OfVentas), 'S/A - Sin Asignar')																															OficinaVentas
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpVend,' - ',T.GrpVend), 'S/A - Sin Asignar')																															GrupoVendedores
,S.Split																																																																Split
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														PlanTon
,A.VentaTonSO																																																												RealTon
,IIF(DAY(A.Fecha)<=DAY(@DiaCierre),A.VentaTonSO,NULL)																																											CorteTon
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),A.VentaTonSO,NULL)																									Ton	
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),A.VentaTonSO,NULL)																											TonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),A.VentaTonSO,NULL)																									TonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														ProyPondTon
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*@DiaHabMesTotal/@DiaHabMesActual	,NULL)							ProyLinealTon
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),-(A.VentaTonSO)/@DiasFaltantes,NULL)																	ObjDiarioTon
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorMes,NULL)																			PromMesTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorMes,NULL)																					PromMesTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorMes,NULL)																				PromMesTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorDiasHab,NULL)																	PromDiasHabTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorDiasHab,NULL)																			PromDiasHabTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorDiasHab,NULL)																		PromDiasHabTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorSemana,NULL)																	PromSemTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorSemana,NULL)																			PromSemTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorSemana,NULL)																		PromSemTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(-(A.VentaTonSO)/@DiasFaltantes) - (A.VentaTonSO)*F.FactorDiasHab, NULL)		PorIncrementarTon
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														PlanSoles
,A.VentaSolesSO																																																												RealSoles
,IIF(DAY(A.Fecha)<=DAY(@DiaCierre),A.VentaSolesSO,NULL)																																										CorteSoles
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),A.VentaSolesSO,NULL)																								Soles	
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),A.VentaSolesSO,NULL)																										SolesMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),A.VentaSolesSO,NULL)																									SolesMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														ProyPondSoles
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*@DiaHabMesTotal/@DiaHabMesActual	,NULL)							ProyLinealSoles
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),-(A.VentaSolesSO)/@DiasFaltantes,NULL)																	ObjDiarioSoles
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorMes,NULL)																		PromMesTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorMes,NULL)																				PromMesTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorMes,NULL)																			PromMesTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																	PromDiasHabTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																			PromDiasHabTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																	PromDiasHabTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorSemana,NULL)																	PromSemTon
,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorSemana,NULL)																			PromSemTonMA
,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorSemana,NULL)																		PromSemTonMAA
,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(-(A.VentaSolesSO)/@DiasFaltantes) - (A.VentaTonSO)*F.FactorDiasHab, NULL)		PorIncrementarSoles
,NULL																																																																PlanAux
,A.CodCategoria
,A.CodFamilia
FROM BaseInicialSellOut A
LEFT JOIN Fechas F ON A.Fecha = F.Fecha
LEFT JOIN MaestroDueñoMarca DM ON A.CodMarca = DM.CodMarca
LEFT JOIN (SELECT * FROM SplitFinal WHERE Split <>0) S ON A.CodDistribuidor = S.CodDistribuidor AND CONCAT(DM.CodDM,'-',A.CodCategoria) = S.CodCategoriaDM AND A.CodFamilia = S.CodFamilia AND A.CodMaterial = S.CodMaterial
LEFT JOIN MaestroTerritorio T ON  A.CodDistribuidor = T.CodDistribuidor AND S.CodTerritorio = T.CodTerritorio;


INSERT INTO BaseSOFinal
SELECT 
@InicioMes																									Fecha
,YEAR(@InicioMes)																						Año
,MONTH(@InicioMes)																					Año
,(SELECT Periodo FROM Fechas WHERE Fecha = @InicioMes)					Periodo
,NULL																											SemanaAño
,NULL																											SemanaRango
,DAY(@InicioMes)																						Dia
,A.Plataforma																								Plataforma
,A.Negocio																									Negocio
,A.Categoria																									Categoria
,A.Familia																										Familia
,A.Marca																										Marca
,CONCAT(A.CodMaterial, ' - ', A.Material)													Material
,A.DueñoMarca																							DueñoMarca
,B.Agrupacion																								Agrrupacion
,CONCAT(A.CodDistribuidor, ' - ', T2.Distribuidor)										Distribuidor
,CONCAT(A.CodTerritorio, ' - ', A.Territorio)												Territorio
,CONCAT(A.CodGrpCond1, ' - ', A.GrpCond1)												GrupoCondiciones
,CONCAT(A.CodGrpPrecios, ' - ', A.GrpPrecios)											GrupoPrecios
,CONCAT(A.CodZnVentas, ' - ', A.ZnVentas)												ZonaVentas
,CONCAT(A.CodOfVentas, ' - ', A.OfVentas)												OficinaVentas
,CONCAT(A.CodGrpVend, ' - ', A.GrpVend)													GrupoVendedores
,0																													Split
,A.PlanTon																									PlanTon
,0																													RealTon
,0																													CorteTon
,0																													Ton
,0																													TonMA
,0																													TonMAA
,0																													ProyPondTon
,0																													ProyLinealTon
,A.PlanTon/@DiasFaltantes																			ObjDiarioTon
,0																													PromMesTon
,0																													PromMesTonMA
,0																													PromMesTonMAA
,0																													PromDiasHabTon
,0																													PromDiasHabTonMA
,0																													PromDiasHabTonMAA
,0																													PromSemTon
,0																													PromSemTonMA
,0																													PromSemTonMAA
,A.PlanTon/@DiasFaltantes																			PorIncrementarTon
,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)					PlanSoles
,NULL																											RealSoles
,NULL																											CorteSoles
,NULL																											Soles
,NULL																											SolesMA
,NULL																											SolesMAA
,0																													ProyPondSoles
,0																													ProyLinealSoles
,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)	/@DiasFaltantes						ObjDiarioSoles
,0																													PromMesSoles
,0																													PromMesSolesMA
,0																													PromMesSolesMAA
,0																													PromDiasHabSoles
,0																													PromDiasHabSolesMA
,0																													PromDiasHabSolesMAA
,0																													PromSemSoles
,0																													PromSemSolesMA
,0																													PromSemSolesMAA
,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)		/@DiasFaltantes					PorIncrementarSoles
,NULL																											PlanAux
,A.CodCategoria
,A.CodFamilia
FROM BasePlanSell_In A
LEFT JOIN (SELECT DISTINCT CodDistribuidor, Agrupacion FROM BaseInicialSellOut) B ON A.CodDistribuidor = B.CodDistribuidor
LEFT JOIN (SELECT DISTINCT CodDistribuidor, Distribuidor FROM BaseInicialSellOut) T2 ON A.CodDistribuidor = T2.CodDistribuidor
LEFT JOIN (SELECT DISTINCT A.CodDistribuidor, A.CodMaterial, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = MONTH(@DiaMA)  GROUP BY  A.CodDistribuidor, A.CodMaterial) ST ON A.CodDistribuidor = ST.CodDistribuidor AND A.CodMaterial = ST.CodMaterial
LEFT JOIN (SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) =MONTH(@DiaMA)  GROUP BY  A.CodDistribuidor, A.CodFamilia) ST2 ON A.CodDistribuidor = ST2.CodDistribuidor AND A.CodFamilia = ST2.CodFamilia;
--LEFT JOIN (SELECT DISTINCT A.CodDistribuidor, A.CodCategoria, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = MONTH(@DiaMA)  GROUP BY  A.CodDistribuidor, A.CodCategoria) ST3 ON A.CodDistribuidor = ST3.CodDistribuidor AND A.CodCategoria = ST3.CodCategoria


--SELECT DISTINCT A.CodDistribuidor, A.CodMaterial, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 6  AND A.CodMaterial in ('3300227','3300110') GROUP BY  A.CodDistribuidor, A.CodMaterial 


DELETE BaseSOFinal
WHERE
(RealTon = 0 OR RealTon IS NULL) AND (RealSoles = 0 OR RealSoles IS NULL) AND (PlanTon = 0 OR PlanTon IS NULL) AND (PlanSoles = 0 OR PlanSoles IS NULL);

IF  @DiaReporte > @FinMes
BEGIN
	UPDATE BaseSOFinal
	SET CorteTon = RealTon
	,CorteSoles = RealSoles
END;

UPDATE VARIABLES
		SET VARIABLE = CASE INDICADOR
			WHEN 1 THEN CONVERT(varchar,@DiaCierre,103)
			WHEN 2 THEN CONVERT(varchar,@DiaReporte,103)
			WHEN 3 THEN CONVERT(varchar,@InicioMes,103)
			WHEN 4 THEN CONVERT(varchar,@FinMes,103)
			WHEN 5 THEN CONVERT(varchar,@DiaHabMesTotal)
			WHEN 6 THEN CONVERT(varchar,@DiaHabMesActual)
			WHEN 7 THEN (SELECT Periodo FROM Fechas WHERE Fecha = @DiaCierre)
			WHEN 8 THEN (SELECT Periodo FROM Fechas WHERE Fecha = @DiaMA)
			WHEN 9 THEN (SELECT Periodo FROM Fechas WHERE Fecha = @DiaMAA)
			WHEN 10 THEN CONVERT(varchar, (SELECT DiasLabAcum FROM Fechas WHERE Fecha = EOMONTH(@DiaMA)))
			WHEN 11 THEN CONVERT(varchar,(SELECT MAX(DiasLabAcum) FROM Fechas WHERE FactorSemana <>0 AND Año = YEAR(@DiaMA) AND Mes = MONTH(@DiaMA)))
			WHEN 12 THEN CONVERT(varchar, (SELECT DiasLabAcum FROM Fechas WHERE Fecha = EOMONTH(@DiaMAA)))
			WHEN 13 THEN CONVERT(varchar,(SELECT MAX(DiasLabAcum) FROM Fechas WHERE FactorSemana <>0 AND Año = YEAR(@DiaMAA) AND Mes = MONTH(@DiaMAA)))
		END;

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000009039%'  -- R&G 
--DELETE BaseSOFinal WHERE Distribuidor LIKE '1000018865%' or Distribuidor LIKE '1000018366%' ;

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000009118%' -- COMERCIO E INVERSION

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000029670%' -- FK SUR

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000003899%'; ---CORREGIR EN EL PLAN
-----
--SELECT		LEFT(Distribuidor,10) CodDistribuidor, 
--				Distribuidor,
--				LEFT(Material,7) CodMaterial,
--				Material, 
--				ABS(COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) Diferencia
--FROM BaseSOFinal    
--GROUP BY Distribuidor, Material  
--HAVING ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) > 0.1

-- SELECT * FROM BaseSOFinal
-- DELETE BaseSOFinal WHERE Material LIKE '3300110%' OR Material LIKE '3300227%'
-- DELETE BaseSOFinal WHERE PlanSoles > 1500


UPDATE BaseSOFinal
	SET	PlanAux = BF.PlanTon*ST.SolTon
	FROM
	BaseSOFinal BF,
	(SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) =MONTH(@DiaMA) GROUP BY  A.CodDistribuidor, A.CodFamilia) ST
	WHERE 
	LEFT(BF.Distribuidor,10) = ST.CodDistribuidor 
	AND 
	BF.CodFamilia = ST.CodFamilia
	AND
	CONCAT(BF.Distribuidor,BF.Material) IN (SELECT CONCAT(Distribuidor,Material)
																		FROM BaseSOFinal  
																		GROUP BY Distribuidor, Material  
																		HAVING ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) > 0.005 AND (SUM(PlanSoles) IS NOT NULL OR  SUM(PlanSoles)  <> 0) ) 
UPDATE BaseSOFinal
SET PlanSoles = BF.PlanAux
FROM
BaseSOFinal BF
WHERE
CONCAT(BF.Distribuidor,BF.Material) IN (SELECT CONCAT(Distribuidor,Material)
																		FROM BaseSOFinal  
																		GROUP BY Distribuidor, Material  
																		HAVING   ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanAux),0),0)) < ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) )




















--SELECT		LEFT(Distribuidor,10) CodDistribuidor, 
--				Distribuidor,
--				LEFT(Material,7) CodMaterial,
--				Material, 
--				ABS(COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanAux),0),0)) Diferencia
--FROM BaseSOFinal    
--GROUP BY Distribuidor, Material  
--HAVING ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) > 0.1

--alter table basesofinal add CodCategoria varchar(20), CodFamilia varchar(20)


/*
SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, A.CodMaterial, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 3 GROUP BY  A.CodDistribuidor, A.CodFamilia, A.CodMaterial
SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) =3 GROUP BY  A.CodDistribuidor, A.CodFamilia
SELECT DISTINCT A.CodDistribuidor, A.CodCategoria, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 3 GROUP BY  A.CodDistribuidor, A.CodCategoria



*/
--DELETE BaseSOFinal WHERE Distribuidor LIKE '1000018861%'  AND Dia > 27

--UPDATE BaseSOFinal
--SET ObjDiarioTon = (PlanTon - Ton)/(2),
--ProyLinealTon = Ton*24/22
--, PorIncrementarTon = (ObjDiarioTon - PromDiasHabTon )
--WHERE Distribuidor LIKE '1000018861%' 





--  SELECT * FROM Fechas
--SELECT * FROM SplitFinal where Split =1

-- SELECT DISTINCT CodDistribuidor, CodCategoriaDM, CodFamilia, Codmaterial FROM SplitFinal where Split =1

--SELECT * FROM BaseSOFinal
--SELECT * FROM BaseInicialSellOut where PERIODO = 202203


--SELECT * FROM VARIABLES
--SELECT * FROM MaestroTerritorio WHERE CodDistribuidor = '1000028662' 
--SELECT * FROM SplitFinal WHERE CodDistribuidor = '1000028662' AND CodTerritorio = '1002042'
--SELECT DISTINCT CodTerritorio FROM MaestroTerritorio
--SELECT DISTINCT CodTerritorio FROm SplitFinal

--SELECT Periodo, CONCAT(CodDistribuidor,' - ', Distribuidor) ,SUM(VentaTonSO) FROM BaseInicialSellOut GROUP BY Periodo, CodDistribuidor, Distribuidor ORDER BY Periodo, CodDistribuidor, Distribuidor

--SELECT * FROM PreSplit

/*
SPLIT:
Vista PreSplit: 
1° Busca el historico todas las combinaciones (BASE SELL OUT) posibles entre CodDistribuidor, CodCategoria-Dueño de Marca, Cod Familia, COd Material
2° Para cada Distribuidor busca todos los Territorios (SELL IN) que le han vendido al distribuidor
3° Realiza un LEFT JOIN Obteniendo todas las posibles combinaciones entre eñ 1° y 2 °
Ejemplo:

PreSplit 
El Distribuidor 1000007527 Vende la DueñoMarca/Categoria 1-1003005 de la Familia 1003005037 del Material 6610005

Combinacion Sell Out 

1000007527			1-1003005			1003005037			6610005

En el Sell In (El Codistribuidor tiene 3 territorios 1002022 // 1003011 // 1004024)
Se crea la Combinacion para el SPLIT 

1000007527			1-1003005			1003005037			6610005			1002022
1000007527			1-1003005			1003005037			6610005			1003011
1000007527			1-1003005			1003005037			6610005			1004024

Una vez creada todas las combinaciones Se realiza El split en distintos niveles Segun el Historico SELL IN

	- 1er Nivel. Se analiza las Ventas Reales TON Por CoDistibuidor / Territorio / Material / Ventas Reales Ton (Se hace un Split De este Material Cuanto ha vendido cada territorio)
	- 2do Solo En caso no haya venta por lo que no se peude generar un split por territoio se va en el segundo Nivel. Se analiza El Plan Por CoDistibuidor / Territorio / Material /Plan Ton (Se hace un Split De este Material Cuanto se ha asignado en plan para cada territorio)
	- 3ro Solo En caso no haya Plan a nivel Material por lo que no se peude generar un split por territoio se va al tercer Nivel. Se analiza las ventas  Por CoDistibuidor / Territorio / Familia / Ventas Reales Ton (Se hace un Split De esta Familia Cuanto ha vendido cada territorio)
	- 4to Nivel. Se analiza El plas TON Por familia Por CoDistibuidor / Territorio / Familia / Plan Ton (Se hace un Split De este Material Cuanto ha vendido cada territorio)
	- 5to Nivel CoDistibuidor / Territorio / DueñodeMarca-Categoria / Real Ton
	- 6to NIvel CoDistibuidor / Territorio / DueñodeMarca-Categoria / Plan Ton

	- En caso no se haya podido obtener el Split (NULL) por los 6 niveles Se asigna un solo Territorio (S/A) y se le da el Split de 1 

	Al Ejemplo

1000007527			1-1003005			1003005037			6610005			1002022			NULL
1000007527			1-1003005			1003005037			6610005			1003011			NULL
1000007527			1-1003005			1003005037			6610005			1004024			NULL

Se convierte en una sola fila

1000007527			1-1003005			1003005037			6610005			S/A					1 (Split 1)


*/


--------------------------------------------------------------------------------------------------------------
-----------------------------------PROCEDIMIENTO (IDEA DEL SPLIT)---------------------------------------
----------------------------------------------------------------------------------------------------------------
/*
			1. Se descarga el historico de venta Sell In Quiebres (Distribuidor, Plataforma, Categoria, Familia, Material y Territorio)
				¿Porque? Se requiere realizar un Split a nivel Territorio, El primer Nivel sera Material (La venta Sell Out de un material se distribuye a Todos los Territorios en funcion a su venta Sell In para un mismo distribuidor)
				¿Que pasa si la venta Sell Out de un  material no se encuentra en el historico de Sell In? ¿Como hago el Split? En caso de que un material no se encuentre en el Sell In, se hara la distribucion en funcion a la Venta Sell In de la Familia para un mismo Distribuidor
				¿Y si sucede con la Familia? Pasa al nivel Categoria y por ultimo a nivel Plataforma
				¿Que pasa si no hay hasta nivel Plataforma? Es muy dificil que suceda eso, ya que involucraria que nunca se vendio una plataforma a un distribuidor, si eso sucede el BackUp sera Dividir el Sell Out en igual porporcion entre todos los Territorios
*/
----------------------------------------------------------------------------------------------------------------
------------------------CREANDO LAS VISTAS PARA LAS BASES DE LOS SPLIT-----------------------------
------------NO ES NECESARIO VOLVERLOS A CORRER, SOLO SI ELIMINASTE ALGUNA VISTA-----------
----------------------------------------------------------------------------------------------------------------
/*
			2. Las Vistas Base Distribuidor + (Material, Familia, Categoria, Plataforma) + Territorio
				Muestra la Venta De cada distribuidor con su respectivo territorio

CREATE VIEW BaseSplitMaterial	 -- Muestra El historico A nivel Distribuidor, Familia, Material, Territorio y Su Venta historica
AS
SELECT CodDistribuidor, CodMaterial, CodTerritorio, VentaSplit  FROM BaseSplit
GO
CREATE VIEW BaseSplitFamilia	-- Muestra El historico A nivel Distribuidor, Familia, Territorio  y Su Venta historica
AS
SELECT CodDistribuidor, CodFamilia, CodTerritorio, SUM(VentaSplit) VentaFamilia FROM BaseSplit GROUP BY CodDistribuidor, CodFamilia, CodTerritorio
GO

CREATE VIEW BaseSplitCategoria	-- Muestra El historico A nivel Distribuidor, Categoria, Territorio  y Su Venta historica
AS
SELECT CodDistribuidor, CONCAT(CodDM,'-',CodCategoria) CodCategoriaDM, CodTerritorio, SUM(VentaSplit) VentaCategoriaDM
FROM BaseSplit 
GROUP BY CodDistribuidor, CodDM, CodCategoria, CodTerritorio
GO



*/
----------------------------------------------------------------------------------------------------------------
-----------------------CREANDO LAS VISTAS PARA LAS BASES Sell_In Totales-----------------------------
------------NO ES NECESARIO VOLVERLOS A CORRER, SOLO SI ELIMINASTE ALGUNA VISTA-----------
----------------------------------------------------------------------------------------------------------------
/*
			2. Muestra la Venta de total por distribuidor Considerando todos los Territorios

CREATE VIEW Sell_InTotalMaterial   -- Muestra la Venta historica a nivel Distribuidor, Familia, Material y La venta de todos los territorios (Nivel Material) 
AS
SELECT CodDistribuidor, CodMaterial, SUM(VentaSplit) TotalMaterial, COUNT(DISTINCT CodTerritorio) CantTerritorio FROM BaseSplit GROUP BY CodDistribuidor, CodMaterial 
GO

CREATE VIEW Sell_InTotalFamilia  -- Muestra la Venta historica a nivel Distribuidor, Familia  y La venta de todos los territorios (Nivel Familia)
AS
SELECT CodDistribuidor, CodFamilia, SUM(VentaSplit) TotalFamilia, COUNT(DISTINCT CodTerritorio) CantTerritorio FROM BaseSplit GROUP BY CodDistribuidor, CodFamilia
GO

CREATE VIEW Sell_InTotalCategoria -- Muestra la Venta historica a nivel Distribuidor, Categoria  y La venta de todos los territorios (Nivel Cetegoria)
AS
SELECT CodDistribuidor, CONCAT(CodDM,'-',CodCategoria) CodCategoriaDM, SUM(VentaSplit) TotalCategoriaDM,  COUNT(DISTINCT CodTerritorio) CantTerritorio FROM BaseSplit GROUP BY CodDistribuidor, CONCAT(CodDM,'-',CodCategoria) 
GO

*/
----------------------------------------------------------------------------------------------------------------
-------------------------CREANDO LAS VISTAS PARA LAS BASES PRE SPLIT-------------------------------
------------NO ES NECESARIO VOLVERLOS A CORRER, SOLO SI ELIMINASTE ALGUNA VISTA-----------
----------------------------------------------------------------------------------------------------------------
/*
				3. Muestran todas plas posibles combinaciones a repartir por territorio

CREATE VIEW PreSplit   -- 
AS
SELECT  DISTINCT A.[CodDistribuidor], CONCAT(DM.CodDM, '-', A.[CodCategoria]) CodCategoriaDM, A.[CodFamilia], A.[CodMaterial], B.[CodTerritorio] FROM 
[EVA_PERU].[dbo].[BaseInicialSellOut] A 
LEFT JOIN MaestroDueñoMarca DM ON A.CodMarca = DM.CodMarca
LEFT JOIN (SELECT DISTINCT [CodDistribuidor], [CodTerritorio] FROM BaseSplit) B 
ON A.CodDistribuidor = B.CodDistribuidor 
GO

SELECT DISTINCT CodDistribuidor, CodMaterial FROM BaseInicialSellOut
*/
----------------------------------------------------------------------------------------------------------------
--------------------CREANDO LAS VISTAS PARA LOL SPLIT POR CADA QUIEBRE--------------------------
------------NO ES NECESARIO VOLVERLOS A CORRER, SOLO SI ELIMINASTE ALGUNA VISTA-----------
----------------------------------------------------------------------------------------------------------------
/*
					4. Brinda los split Asignado a cada Territorio
CREATE VIEW SplitMaterial
AS
SELECT A.CodDistribuidor,  A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, A.CodTerritorio, ISNULL(B.VentaSplit,0)/IIF(C.TotalMaterial=0,NULL,C.TotalMaterial) SplitTon
FROM PreSplit A
LEFT JOIN BaseSplitMaterial B ON A.CodDistribuidor = B.CodDistribuidor AND A.CodTerritorio = B.CodTerritorio AND A.CodMaterial = B.CodMaterial
LEFT JOIN Sell_InTotalMaterial C ON A.CodDistribuidor = C.CodDistribuidor AND A.CodMaterial = C.CodMaterial
GO

CREATE VIEW SplitFamilia
AS
SELECT A.CodDistribuidor, A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, A.CodTerritorio, ISNULL(B.VentaFamilia,0)/IIF(C.TotalFamilia = 0, NULL, C.TotalFamilia)  SplitTon
FROM PreSplit A
LEFT JOIN BaseSplitFamilia B ON A.CodDistribuidor = B.CodDistribuidor AND A.CodTerritorio = B.CodTerritorio AND A.CodFamilia = B.CodFamilia
LEFT JOIN Sell_InTotalFamilia C ON A.CodDistribuidor = C.CodDistribuidor AND A.CodFamilia = C.CodFamilia
GO

CREATE VIEW SplitCategoria
AS
SELECT A.CodDistribuidor,  A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, A.CodTerritorio, ISNULL(B.VentaCategoriaDM,0)/IIF(C.TotalCategoriaDM=0,NULL,C.TotalCategoriaDM) SplitTon
FROM PreSplit A
LEFT JOIN BaseSplitCategoria B ON A.CodDistribuidor = B.CodDistribuidor AND A.CodTerritorio = B.CodTerritorio AND A.CodCategoriaDM = B.CodCategoriaDM
LEFT JOIN Sell_InTotalCategoria C ON A.CodDistribuidor = C.CodDistribuidor AND A.CodCategoriaDM = C.CodCategoriaDM
GO

*/

--SELECT DISTINCT CONCAT(A.CodDistribuidor, ' - ',A.CodMaterial) Dist_Mat , COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 2 GROUP BY  A.CodDistribuidor, A.CodMaterial

--SELECT DISTINCT CONCAT(A.CodDistribuidor, ' - ', A.CodMaterial) Dist_Mat, SUM(A.VentaSolesSO) Sol, SUM(A.VentaTonSO) Ton FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 2 GROUP BY  A.CodDistribuidor, A.CodMaterial

--SELECT DISTINCT CONCAT(A.CodDistribuidor, ' - ',A.CodFamilia) Dist_Mat , COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = 2 GROUP BY  A.CodDistribuidor, A.CodFamilia

-- SELECT * FROM BaseInicialSellOut WHERE CodMaterial in ('8325003','8325002')





--DROP TABLE #CONSOLIDADO1
--SELECT  A.Dia, B.Familia , ISNULL(C.VentaTonSO,0) VentaTonSO
--INTO #CONSOLIDADO1
--FROM (SELECT DISTINCT DAY(Fecha) Dia FROM BaseInicialSellOut) A
--CROSS JOIN (SELECT DISTINCT Familia FROM BaseInicialSellOut WHERE DISTRIBUIDOR = 'CORPORACION SAGRA S.A.' AND Periodo = '202204') B
--LEFT JOIN (SELECT DAY(Fecha) Dia, Familia, SUM(VentaTonSO) VentaTonSO FROM BaseInicialSellOut WHERE DISTRIBUIDOR = 'CORPORACION SAGRA S.A.' AND Periodo = '202204' GROUP BY DAY(Fecha), Familia) C 
--ON B.Familia = C.Familia AND A.Dia =C.Dia
--ORDER BY A.Dia, B.Familia

--SELECT * FROM #CONSOLIDADO1

--DROP TABLE #CONSOLIDADO2


--SELECT A.Dia, A.Familia, MAX(A.VentaTonSO) Sub_Total, SUM(B.VentaTonSO) Total_Acum
--INTO #CONSOLIDADO2 
--FROM #CONSOLIDADO1 A
--LEFT JOIN #CONSOLIDADO1 B
--ON B.Dia <= A.Dia AND A.Familia = B.Familia
--GROUP BY A.Dia, A.Familia
--ORDER BY 1 ASC, 2 ASC

--SELECT * FROM #CONSOLIDADO2


----SELECT Familia, SUM(PORC) FROM (
--SELECT A.Dia,A.Familia, A.VentaTonSO, B.Total_Acum, COALESCE(A.VentaTonSO/NULLIF(B.Total_Acum,0),0) PORC
--FROM #CONSOLIDADO1 A
--LEFT JOIN #CONSOLIDADO2 B
--ON A.Dia <= B.Dia AND A.Familia = B.Familia
--WHERE B.Dia = 20

-- --) A GROUP BY A.Familia
-- --SELECT DISTINCT FAMILIA FROM BaseInicialSellOut WHERE DISTRIBUIDOR = 'CORPORACION SAGRA S.A.' AND Periodo = '202204'


--DROP TABLE #CONSOLIDADO1
--SELECT  A.Dia, B.Familia , ISNULL(C.VentaTonSO,0) VentaTonSO
--INTO #CONSOLIDADO1
--FROM (SELECT DISTINCT DAY(Fecha) Dia FROM BaseInicialSellOut ) A
--CROSS JOIN (SELECT DISTINCT Familia FROM BaseInicialSellOut) B
--LEFT JOIN (SELECT DAY(Fecha) Dia, Familia, SUM(VentaTonSO) VentaTonSO FROM BaseInicialSellOut GROUP BY DAY(Fecha), Familia) C 
--ON B.Familia = C.Familia AND A.Dia =C.Dia
--ORDER BY A.Dia, B.Familia


SELECT Agrupacion, A.CodCategoria, A.Categoria, A.CodFamilia, A.Familia, A.CodMaterial, A.Material,  Round(COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VenTaUnidSO),0),0)*1000,2) PU, Round(COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0),2) SolTon_Agrupacion, Round(AVG(B.SolTon_Promedio),2) SolTon_Promedio, IIF(ABS(COALESCE(COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0)/NULLIF(AVG(B.SolTon_Promedio),0),0) -1)>=0.5,COALESCE(COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0)/NULLIF(AVG(B.SolTon_Promedio),0),0) -1 ,NULL) Diferencia FROM BaseInicialSellOut A 
LEFT JOIN
(
SELECT  CodCategoria, Categoria, CodFamilia, Familia, CodMaterial, Material, COALESCE(SUM(VentaSolesSO)/NULLIF(SUM(VentaTonSO),0),0) SolTon_Promedio FROM BaseInicialSellOut  
GROUP BY  CodCategoria, Categoria, CodFamilia, Familia, CodMaterial, Material
) B
ON A.CodCategoria = B.CodCategoria AND A.Categoria = B.Categoria AND A.CodFamilia = B.CodFamilia AND A.Familia = B.Familia AND A.CodMaterial = B.CodMaterial 
GROUP BY  Agrupacion, A.CodCategoria, A.Categoria, A.CodFamilia, A.Familia, A.CodMaterial, A.Material
ORDER BY  A.CodCategoria, A.CodFamilia, A.CodMaterial, A.Material, Diferencia desc









