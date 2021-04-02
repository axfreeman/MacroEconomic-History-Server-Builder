/* The queries below create four CLEANED Definitions:

 MACROHIST:rgdppc_deindexed reconstructs GDP per capita from MACROHIST:rgdppc, which is indexed to the year 2005,
 by multiplying it by WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2005].
 
 MACROHIST:rgdp multiplies this by popularion to obtain a long real GDP series calibrated with 
 WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT for the years above 1960
 
 */

-- Create a View with the MACROHIST Indexed GDP in it
USE [macrohistory_rolap_23.01.2021]
GO

CREATE OR ALTER VIEW [dbo].[Macrohist_Indexed_rgdppc]
AS
-- Prepare to De-index rgdppc
SELECT 
 [SourceName],
 N'COPY OF RGDPPC INDEXED' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='MACROHIST' and [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2005'
 GO
 
 

-- [WDI2020_2005_REALGDP_BASE]contains, for each GeoID, the real GDP per capita taken from 
-- WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2005] (the base year for the MACROHIST:rgdppc index)
 
CREATE OR ALTER VIEW [dbo].[WDI2020_2005_REALGDP_BASE]
AS
 -- Select only year 2005 and the GeoID. As before, select GeoStandardName so we can see what's going on
SELECT
 [DimGeoID],
 N'COPY OF WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2005' AS indicatorStandardName,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].SourceName='WDI2020' 
 AND [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND Year([FactQuery].DateField)=2005
GO
 
-- [Macrohist_WDI2020_Deindexed] uses [Macrohist_indexed] and [WDI2020_2005_REALGDP_BASE] to construct a de-indexed rgdppc

CREATE OR ALTER VIEW [dbo].[Macrohist_WDI2020_Deindexed]
AS
SELECT 
 dbo.Macrohist_Indexed_rgdppc.DimGeoID,
 dbo.Macrohist_Indexed_rgdppc.indicatorStandardName, 
 dbo.Macrohist_Indexed_rgdppc.DateField,
 dbo.Macrohist_Indexed_rgdppc.Value AS [Index],
 dbo.WDI2020_2005_REALGDP_BASE.Value AS Base,
 dbo.Macrohist_Indexed_rgdppc.Value*dbo.WDI2020_2005_REALGDP_BASE.Value/100 as Value
FROM dbo.Macrohist_Indexed_rgdppc LEFT OUTER JOIN
  dbo.WDI2020_2005_REALGDP_BASE ON 
  dbo.WDI2020_2005_REALGDP_BASE.DimGeoID = dbo.Macrohist_Indexed_rgdppc.DimGeoID
GO

-- Create a View with MADDISON:Population in it

CREATE OR ALTER VIEW [dbo].[Maddison_Population]
AS

SELECT 
 [SourceName],
 N'COPY OF MADDISON:POPULATION' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='MADDISON' and [FactQuery].indicatorStandardName='Population'
 GO
 
-- use [Macrohist_WDI2020_Deindexed], Maddison_Population and Macrohist itself to construct [Macrohist_WDI2020_rgdp]

CREATE OR ALTER VIEW [dbo].[Macrohist_cleaner]
AS
SELECT 
 N'MACROHIST' AS SourceName,
 dbo.Macrohist_WDI2020_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS indicatorStandardName,
 dbo.Macrohist_WDI2020_Deindexed.DateField,
 dbo.Maddison_Population.Value*Macrohist_WDI2020_Deindexed.Value as Value
FROM dbo.Macrohist_WDI2020_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.DateField=Macrohist_WDI2020_Deindexed.DateField AND
  dbo.Maddison_Population.DimGeoID=Macrohist_WDI2020_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.indicatorStandardName='GDP-TOTAL-LCU-CONSTANT2010'
GO

/*
BARRO_URSUA:gdp_deindexed reconstructs GDP per capita from BARRO_URSUA:GDP per Capita, 2006=100 which is indexed to the year 2006,
 by multiplying it by WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2006].
 
 BARRO_URSUA:gdp multiplies this by MACROHIST:pop to obtain a long real GDP series calibrated with 
 WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT for the years above 1960
 */

 -- Create a View with the BARRO_URSUA Indexed GDP in it

CREATE OR ALTER VIEW [dbo].[Barro_Ursua_Indexed_gdp]
AS
-- Prepare to De-index GDP
SELECT 
 [SourceName],
 N'COPY OF GDP INDEXED' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='BARRO-URSUA' and [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2006'
 GO

 -- [WDI2020_2006_REALGDP_BASE]contains, for each GeoID, the real GDP per capita taken from 
-- WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2006] (the base year for the MACROHIST:rgdppc index)
 
CREATE OR ALTER VIEW [dbo].[WDI2020_2006_REALGDP_BASE]
AS
 -- Select only year 2006 and the GeoID. As before, select GeoStandardName so we can see what's going on
SELECT
 [DimGeoID],
 N'COPY OF WDI2020:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2006' AS indicatorStandardName,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].SourceName='WDI2020' 
 AND [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND Year([FactQuery].DateField)=2006
GO
 

-- [BARRO-URSUA_WDI2020_Deindexed] uses [Barro_Ursua_Indexed_gdp] and [WDI2020_2006_REALGDP_BASE] to construct a de-indexed rgdppc

CREATE OR ALTER VIEW [dbo].[BARRO_URSUA_WDI2020_Deindexed]
AS
SELECT 
 dbo.Barro_Ursua_Indexed_gdp.DimGeoID,
 dbo.Barro_Ursua_Indexed_gdp.indicatorStandardName, 
 dbo.Barro_Ursua_Indexed_gdp.DateField,
 dbo.Barro_Ursua_Indexed_gdp.Value AS [Index],
 dbo.WDI2020_2006_REALGDP_BASE.Value AS Base,
 dbo.Barro_Ursua_Indexed_gdp.Value*dbo.WDI2020_2006_REALGDP_BASE.Value/100 as Value
FROM dbo.Barro_Ursua_Indexed_gdp LEFT OUTER JOIN
  dbo.WDI2020_2006_REALGDP_BASE ON 
  dbo.WDI2020_2006_REALGDP_BASE.DimGeoID = dbo.Barro_Ursua_Indexed_gdp.DimGeoID
GO

-- [Barro_Ursua_cleaner] uses Barro_Ursua_WDI2020_Deindexed] and Barro_Ursua itself to construct [Barro_Ursua_WDI2020_rgdp]

CREATE OR ALTER VIEW [dbo].[Barro_Ursua_cleaner]
AS
SELECT 
 N'BARRO-URSUA' AS SourceName,
 dbo.Barro_Ursua_WDI2020_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS indicatorStandardName,
 dbo.Barro_Ursua_WDI2020_Deindexed.DateField,
 dbo.Maddison_Population.Value*Barro_Ursua_WDI2020_Deindexed.Value as Value
FROM dbo.Barro_Ursua_WDI2020_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.DateField=Barro_Ursua_WDI2020_Deindexed.DateField AND
  dbo.Maddison_Population.DimGeoID=Barro_Ursua_WDI2020_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.indicatorStandardName='GDP-TOTAL-LCU-CONSTANT2010'
GO

-- APPEND THE NEW DEFINITIONS TO THE ADDED_DEFINITIONS TABLE

CREATE OR ALTER VIEW [dbo].[AddedDefinitions]
AS
SELECT 
 [SourceName],
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM [dbo].[Macrohist_cleaner]
UNION
SELECT 
 [SourceName],
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM [dbo].[Barro_Ursua_cleaner]
GO

-- we have to now recover the indexes for source before finally putting the result into the fact file.

CREATE OR ALTER VIEW [dbo].[NormalisedAddedDefinitions]
AS
SELECT
 [DimSourceID],
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM AddedDefinitions
INNER JOIN DimSource ON
AddedDefinitions.SourceName=DimSource.SourceName
GO

-- Finally insert all the new material into the fact file

INSERT INTO Fact(
 [DimSourceID],
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value])
SELECT
 [DimSourceID],
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM NormalisedAddedDefinitions
GO 
 


 