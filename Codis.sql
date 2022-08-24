USE Lanzamientos;

TRUNCATE TABLE MaestroTerritorio -- LLave CodDistribuidor-CodTerritorio para asignar Of.Ventas, Grp Precios, Grp Vendedores, etc.

BULK INSERT MaestroTerritorio
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\MaestroTerritorioCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP')

UPDATE MaestroTerritorio
SET CodDistribuidor = RIGHT(CodDistribuidor,10)


SET LANGUAGE SPANISH;

TRUNCATE TABLE BaseInicialSellOut;			-- Base del mes actual-Mes en curso

BULK INSERT BaseInicialSellOut
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\VentasCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP');

SET LANGUAGE US_ENGLISH;


DELETE FROM BaseInicialSellOut
WHERE CodMaterial IS NULL OR CodMaterial = 0;
----------------------------------------------------------------------------------------------------------------
-------------------------- CONSERVANDO SOLO NEGOCIO CORE Y VALUE--------------------------------
----------------------------------------------------------------------------------------------------------------
--VER
DELETE FROM BaseInicialSellOut
WHERE Negocio not in ('Core','Value');


TRUNCATE TABLE BaseSplit;

BULK INSERT BaseSplit
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\BaseSplitTonCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP');

UPDATE BaseSplit
SET CodDistribuidor = RIGHT(CodDistribuidor,10);

----------------------------------------------------------------------------------------------------------------
-------------------------------INGRESANDO LA BASE PRE SPLIT HISTORICO-----------------------------------
----------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE PreSplitHistorico

BULK INSERT PreSplitHistorico
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\PreSplitHistoricoCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP');

DELETE FROM PreSplitHistorico WHERE CodMaterial = '0'

---------------------------INGRESANDO MAESTRO DUEÑO DE MARCA---------------------------------
----------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE MaestroDueñoMarca;

BULK INSERT MaestroDueñoMarca
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\MaestroDMCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP');

----------------------------------------------------------------------------------------------------------------
-------------------------------INGRESANDO LA BASE PLAN SELL IN------------------------------------
----------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE BasePlanSell_In

BULK INSERT BasePlanSell_In
FROM 'C:\Proyectos\Peru\BaseDatos\Lanzamiento_Peru\CargaBases\BasePlanSellInCodis.csv'
WITH (FIELDTERMINATOR =';', FIRSTROW=2, CODEPAGE='ACP');

UPDATE BasePlanSell_In SET Fecha = REPLACE(Fecha, '.', '/');

--IF OBJECT_ID(N'tempdb..#PRUEBA') IS NOT NULL DROP TABLE #PRUEBA;

--SELECT CONVERT(DATE, A.fecha, 103) Fecha
--INTO #PRUEBA
--FROM BasePlanSell_In A
--SELECT * FROM #PRUEBA

--VER FECHAS


---------------------------------------------------------------------------------------------------------------
---------------------------GENERANDO EL SPLIT MENSUAL TONELADAS---------------------------------
---------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE PreSplit

INSERT INTO PreSplit
SELECT  DISTINCT A.CodDistribuidor, CONCAT(DM.CodDM, '-', A.CodCategoria) CodCategoriaDM, A.CodFamilia, A.CodMaterial, B.CodTerritorio
FROM BaseInicialSellOut A 
	LEFT JOIN MaestroDueñoMarca DM ON A.CodMarca = DM.CodMarca
	LEFT JOIN (SELECT DISTINCT CodDistribuidor, CodTerritorio FROM BaseSplit) B ON A.CodDistribuidor = B.CodDistribuidor;

INSERT INTO PreSplit
SELECT DISTINCT A.CodDistribuidor, A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, B.CodTerritorio
FROM PreSplitHistorico A
	LEFT JOIN (SELECT DISTINCT CodDistribuidor, CodTerritorio FROM BaseSplit) B ON A.CodDistribuidor = B.CodDistribuidor																													
WHERE A.CodDistribuidor+A.CodCategoriaDM+A.CodFamilia+A.CodMaterial NOT IN (SELECT DISTINCT CodDistribuidor+CodCategoriaDM+CodFamilia+CodMaterial FROM PreSplit)


TRUNCATE TABLE SplitFinal;

INSERT INTO SplitFinal
SELECT  DISTINCT A.CodDistribuidor,  A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, 
                 ISNULL(IIF(M.SplitTon is NULL  AND F.SplitTon is NULL  AND C.SplitTon is NULL ,NULL,B.CodTerritorio),'S/A') Territorio,  
                 ISNULL(ISNULL(ISNULL(M.SplitTon,F.SplitTon),C.SplitTon),1) Split
FROM PreSplit A
	LEFT JOIN (SELECT DISTINCT [CodDistribuidor], [CodTerritorio] FROM BaseSplit) B ON A.CodDistribuidor = B.CodDistribuidor 
	LEFT JOIN SplitMaterial M ON A.CodDistribuidor = M.CodDistribuidor AND A.CodCategoriaDM = M.CodCategoriaDM 
	                             AND A.CodFamilia = M.CodFamilia AND A.CodMaterial = M.CodMaterial AND B.CodTerritorio = M.CodTerritorio 
	LEFT JOIN SplitFamilia F ON  A.CodDistribuidor = F.CodDistribuidor AND A.CodCategoriaDM = F.CodCategoriaDM
	                             AND A.CodFamilia = F.CodFamilia AND A.CodMaterial = F.CodMaterial AND B.CodTerritorio = F.CodTerritorio
	LEFT JOIN SplitCategoria C ON  A.CodDistribuidor = C.CodDistribuidor  AND A.CodCategoriaDM = C.CodCategoriaDM
							     AND A.CodFamilia = C.CodFamilia AND A.CodMaterial = C.CodMaterial AND B.CodTerritorio = C.CodTerritorio 
ORDER BY A.CodDistribuidor, A.CodCategoriaDM, A.CodFamilia, A.CodMaterial, Territorio;


---- EN CASO EN LA BASE SELL IN UN DISTRIBUIDOR SE ASIGNE A UN SOLO TERRITORIO Y TENGA SPLIT SIN AGINAR, SE BRINDA TODO LA VENTA  A ESE TERRITORIO
UPDATE SplitFinal
SET CodTerritorio = CASE
	WHEN SF.CodTerritorio <> 'S/A' THEN	SF.CodTerritorio
	WHEN SF.CodDistribuidor IN (SELECT T.CodDistribuidor FROM MaestroTerritorio T GROUP BY  T.CodDistribuidor HAVING Count(T.CodTerritorio) = 1)		
							THEN (SELECT T2.CodTerritorio FROM MaestroTerritorio T2 WHERE T2.CodDistribuidor = SF.CodDistribuidor)
							ELSE 'S/A' END
FROM SplitFinal SF;

--- EN CASO HAYA VENTAS DE UN MISMO MATERIAL DOS TERRITORIOS SE TOMA EN CONSIDERACION EL QUE TIENE MAYOR VENTA

--SELECT  CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial, MAX(Split) SplitMax FROM SplitFinal  WHERE Split <> 0 AND Split <> 1 GROUP BY CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial

TRUNCATE TABLE SplitAuxiliar

INSERT INTO SplitAuxiliar
SELECT  B.CodDistribuidor, B.CodCategoriaDM, B.CodFamilia, B.CodMaterial, A.CodTerritorio
FROM SplitFinal A,  
     (SELECT  CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial, MAX(Split) SplitMax
	  FROM SplitFinal WHERE Split <> 0 AND Split <> 1 GROUP BY CodDistribuidor, CodCategoriaDM, CodFamilia, CodMaterial   ) B
WHERE A.CodDistribuidor = B.CodDistribuidor AND A.CodCategoriaDM = B.CodCategoriaDM AND A.CodFamilia = B.CodFamilia AND A.CodMaterial = B.CodMaterial AND A.Split = B.SplitMax;

UPDATE SplitFinal
SET Split = 0
WHERE Split <> 0 AND Split <> 1;

UPDATE SplitFinal
SET Split = 1
FROM SplitFinal A, (SELECT DISTINCT * FROM SplitAuxiliar) B
WHERE A.CodDistribuidor = B.CodDistribuidor AND A.CodCategoriaDM = B.CodCategoriaDM AND A.CodFamilia = B.CodFamilia 
	                      AND A.CodMaterial = B.CodMaterial AND A.CodTerritorio = B.CodTerritorio ;



TRUNCATE TABLE BaseSOFinal

INSERT INTO BaseSOFinal
SELECT 
A.Fecha
--,F.Año														Año
--,F.Mes																																																																MES
--,F.Periodo																																																															Periodo
--,F.Semana_Año																																																												SemanaAño
--,F.Semana																																																														SemanaRango
--,F.Dia																																																																Dia
,A.Plataforma, A.Negocio, A.Categoria, A.Familia, A.Marca, CONCAT(A.CodMaterial, ' - ', A.Material)	Material
,DM.DM	DueñoMarca, A.Agrupacion,
CONCAT(A.CodDistribuidor, ' - ', A.Distribuidor) Distribuidor
,CONCAT(S.CodTerritorio,' - ',IIF(S.CodTerritorio <> 'S/A',T.Territorio,'Sin Asignar'))	Territorio
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpCond1,' - ',T.GrpCond1), 'S/A - Sin Asignar')	GrupoCondiciones
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpPrecios,' - ',T.GrpPrecios), 'S/A - Sin Asignar')	GrupoPrecios
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodZnVentas,' - ',T.ZnVentas), 'S/A - Sin Asignar')	ZonaVentas
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodOfVentas,' - ',T.OfVentas), 'S/A - Sin Asignar')	OficinaVentas
,IIF(S.CodTerritorio <> 'S/A', CONCAT(T.CodGrpVend,' - ',T.GrpVend), 'S/A - Sin Asignar') GrupoVendedores
,S.Split Split
, 0 PlanTon
,A.VentaTonSO RealTon
----,IIF(DAY(A.Fecha)<=DAY(@DiaCierre),A.VentaTonSO,NULL) CorteTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),A.VentaTonSO,NULL)																									Ton	
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),A.VentaTonSO,NULL)																											TonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),A.VentaTonSO,NULL)																									TonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														ProyPondTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*@DiaHabMesTotal/@DiaHabMesActual	,NULL)							ProyLinealTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),-(A.VentaTonSO)/@DiasFaltantes,NULL)																	ObjDiarioTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorMes,NULL)																			PromMesTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorMes,NULL)																					PromMesTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorMes,NULL)																				PromMesTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorDiasHab,NULL)																	PromDiasHabTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorDiasHab,NULL)																			PromDiasHabTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorDiasHab,NULL)																		PromDiasHabTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaTonSO)*F.FactorSemana,NULL)																	PromSemTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaTonSO)*F.FactorSemana,NULL)																			PromSemTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaTonSO)*F.FactorSemana,NULL)																		PromSemTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(-(A.VentaTonSO)/@DiasFaltantes) - (A.VentaTonSO)*F.FactorDiasHab, NULL)		PorIncrementarTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)											
,0 PlanSoles
,A.VentaSolesSO																																																												RealSoles
--,IIF(DAY(A.Fecha)<=DAY(@DiaCierre),A.VentaSolesSO,NULL)																																										CorteSoles
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),A.VentaSolesSO,NULL)																								Soles	
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),A.VentaSolesSO,NULL)																										SolesMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),A.VentaSolesSO,NULL)																									SolesMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),0,NULL)																														ProyPondSoles
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*@DiaHabMesTotal/@DiaHabMesActual	,NULL)							ProyLinealSoles
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),-(A.VentaSolesSO)/@DiasFaltantes,NULL)																	ObjDiarioSoles
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorMes,NULL)																		PromMesTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorMes,NULL)																				PromMesTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorMes,NULL)																			PromMesTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																	PromDiasHabTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																			PromDiasHabTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorDiasHab,NULL)																	PromDiasHabTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(A.VentaSolesSO)*F.FactorSemana,NULL)																	PromSemTon
--,IIF(YEAR(A.fecha)=YEAR(@DiaMA) AND MONTH(A.fecha)=MONTH(@DiaMA),(A.VentaSolesSO)*F.FactorSemana,NULL)																			PromSemTonMA
--,IIF(YEAR(A.fecha)=YEAR(@DiaMAA) AND MONTH(A.fecha)=MONTH(@DiaMAA),(A.VentaSolesSO)*F.FactorSemana,NULL)																		PromSemTonMAA
--,IIF(YEAR(A.fecha)=YEAR(@DiaCierre) AND MONTH(A.fecha)=MONTH(@DiaCierre),(-(A.VentaSolesSO)/@DiasFaltantes) - (A.VentaTonSO)*F.FactorDiasHab, NULL)		PorIncrementarSoles
,NULL PlanAux
,A.CodCategoria
,A.CodFamilia
--INTO BaseSOFinal
FROM BaseInicialSellOut A
--LEFT JOIN Fechas F ON A.Fecha = F.Fecha
	LEFT JOIN MaestroDueñoMarca DM ON A.CodMarca = DM.CodMarca
	LEFT JOIN (SELECT * FROM SplitFinal WHERE Split <>0) S ON A.CodDistribuidor = S.CodDistribuidor AND CONCAT(DM.CodDM,'-',A.CodCategoria) = S.CodCategoriaDM
														      AND A.CodFamilia = S.CodFamilia AND A.CodMaterial = S.CodMaterial
	LEFT JOIN MaestroTerritorio T ON  A.CodDistribuidor = T.CodDistribuidor AND S.CodTerritorio = T.CodTerritorio;



INSERT INTO BaseSOFinal
SELECT 
CONVERT(DATE, A.Fecha, 103) Fecha
--,YEAR(@InicioMes)																						Año
--,MONTH(@InicioMes)																					Año
--,(SELECT Periodo FROM Fechas WHERE Fecha = @InicioMes)					Periodo
--,NULL																											SemanaAño
--,NULL																											SemanaRango
--,DAY(@InicioMes)																						Dia
,A.Plataforma
,A.Negocio
,A.Categoria
,A.Familia
,A.Marca
,CONCAT(A.CodMaterial, ' - ', A.Material) Material
,A.DueñoMarca
,B.Agrupacion
,CONCAT(A.CodDistribuidor, ' - ', T2.Distribuidor)	Distribuidor
,CONCAT(A.CodTerritorio, ' - ', A.Territorio) Territorio
,CONCAT(A.CodGrpCond1, ' - ', A.GrpCond1) GrupoCondiciones
,CONCAT(A.CodGrpPrecios, ' - ', A.GrpPrecios) GrupoPrecios
,CONCAT(A.CodZnVentas, ' - ', A.ZnVentas) ZonaVentas
,CONCAT(A.CodOfVentas, ' - ', A.OfVentas) OficinaVentas
,CONCAT(A.CodGrpVend, ' - ', A.GrpVend)	GrupoVendedores
,0 Split
,A.PlanTon
,0	RealTon
--,0																													CorteTon
--,0																													Ton
--,0																													TonMA
--,0																													TonMAA
--,0																													ProyPondTon
--,0																													ProyLinealTon
--,A.PlanTon/@DiasFaltantes																			ObjDiarioTon
--,0																													PromMesTon
--,0																													PromMesTonMA
--,0																													PromMesTonMAA
--,0																													PromDiasHabTon
--,0																													PromDiasHabTonMA
--,0																													PromDiasHabTonMAA
--,0																													PromSemTon
--,0																													PromSemTonMA
--,0																													PromSemTonMAA
--,A.PlanTon/@DiasFaltantes																			PorIncrementarTon
--,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)	PlanSoles
, A.PlanSoles
,0 	RealSoles
--,NULL																											CorteSoles
--,NULL																											Soles
--,NULL																											SolesMA
--,NULL																											SolesMAA
--,0																													ProyPondSoles
--,0																													ProyLinealSoles
--,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)	/@DiasFaltantes						ObjDiarioSoles
--,0																													PromMesSoles
--,0																													PromMesSolesMA
--,0																													PromMesSolesMAA
--,0																													PromDiasHabSoles
--,0																													PromDiasHabSolesMA
--,0																													PromDiasHabSolesMAA
--,0																													PromSemSoles
--,0																													PromSemSolesMA
--,0																													PromSemSolesMAA
--,A.PlanTon*ISNULL(ST.SolTon,ST2.SolTon)		/@DiasFaltantes					PorIncrementarSoles
,NULL PlanAux
,A.CodCategoria
,A.CodFamilia
FROM BasePlanSell_In A
	LEFT JOIN (SELECT DISTINCT CodDistribuidor, Agrupacion FROM BaseInicialSellOut) B ON A.CodDistribuidor = B.CodDistribuidor
	LEFT JOIN (SELECT DISTINCT CodDistribuidor, Distribuidor FROM BaseInicialSellOut) T2 ON A.CodDistribuidor = T2.CodDistribuidor;
	--LEFT JOIN (SELECT DISTINCT A.CodDistribuidor, A.CodMaterial, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon
	--		   FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) = MONTH(@DiaMA)  GROUP BY  A.CodDistribuidor, A.CodMaterial) ST ON A.CodDistribuidor = ST.CodDistribuidor AND A.CodMaterial = ST.CodMaterial
	----LEFT JOIN (SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon
	--		   FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) =MONTH(@DiaMA)  GROUP BY  A.CodDistribuidor, A.CodFamilia) ST2 ON A.CodDistribuidor = ST2.CodDistribuidor AND A.CodFamilia = ST2.CodFamilia;


DELETE BaseSOFinal
WHERE (RealTon = 0 OR RealTon IS NULL) AND (RealSoles = 0 OR RealSoles IS NULL)
      AND (PlanTon = 0 OR PlanTon IS NULL) AND (PlanSoles = 0 OR PlanSoles IS NULL);

-----Pregunar
DELETE BaseSOFinal WHERE Distribuidor LIKE '1000009039%'  -- R&G 
--DELETE BaseSOFinal WHERE Distribuidor LIKE '1000018865%' or Distribuidor LIKE '1000018366%' ;

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000009118%' -- COMERCIO E INVERSION

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000029670%' -- FK SUR

DELETE BaseSOFinal WHERE Distribuidor LIKE '1000003899%'; ---CORREGIR EN EL PLAN
-------------------------------------------


--UPDATE BaseSOFinal
--SET	PlanAux = BF.PlanTon*ST.SolTon
--	FROM BaseSOFinal BF,
--	(SELECT DISTINCT A.CodDistribuidor, A.CodFamilia, COALESCE(SUM(A.VentaSolesSO)/NULLIF(SUM(A.VentaTonSO),0),0) SolTon
--	 FROM BaseInicialSellOut A WHERE MONTH(A.Fecha) =MONTH(@DiaMA) GROUP BY  A.CodDistribuidor, A.CodFamilia) ST
--	 WHERE LEFT(BF.Distribuidor,10) = ST.CodDistribuidor AND BF.CodFamilia = ST.CodFamilia
--	       AND	CONCAT(BF.Distribuidor,BF.Material) IN (SELECT CONCAT(Distribuidor,Material)
--														FROM BaseSOFinal  
--														GROUP BY Distribuidor, Material  
--														HAVING ABS(COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) > 0.005 AND (SUM(PlanSoles) IS NOT NULL OR  SUM(PlanSoles)  <> 0) ) 

--UPDATE BaseSOFinal
--SET PlanSoles = BF.PlanAux
--FROM
--BaseSOFinal BF
--WHERE
--CONCAT(BF.Distribuidor,BF.Material) IN (SELECT CONCAT(Distribuidor,Material)
--																		FROM BaseSOFinal  
--																		GROUP BY Distribuidor, Material  
--																		HAVING   ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanAux),0),0)) < ABS( COALESCE(SUM(Ton)/NULLIF(SUM(PlanTon),0),0) - COALESCE(SUM(Soles)/NULLIF(SUM(PlanSoles),0),0)) )

