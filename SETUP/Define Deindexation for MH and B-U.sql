/* The queries below create four -EXTENDED Definitions:

 MACROHIST_EXTENDED:rgdppc_deindexed reconstructs GDP per capita from MACROHIST:rgdppc, which is indexed to the year 2005,
 by multiplying it by WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2005].
 
 MACROHIST_EXTENDED:rgdp multiplies this by MADDISON:pop to obtain a long real GDP series calibrated with 
 WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT for the years above 1960
 
 BARRO_URSUA_EXTENDED:gdp_deindexed reconstructs GDP per capita from BARRO_URSUA:GDP per Capita, 2006=100 which is indexed to the year 2006,
 by multiplying it by WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2006].
 
 BARRO_URSUA_EXTENDED:gdp multiplies this by MACROHIST:pop to obtain a long real GDP series calibrated with 
 WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT for the years above 1960
*/

-- Create a View with the MACROHIST Indexed GDP in it

BEGIN TRY
DROP VIEW [dbo].[Macrohist_Indexed_rgdppc]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Macrohist_Indexed_rgdppc]
AS
-- Prepare to De-index rgdppc
SELECT 
 [SourceName],
 N'COPY OF RGDPPC INDEXED' AS IndicatorStandardCode,
 [DimGeoID],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='MACROHIST' and [FactQuery].IndicatorStandardCode='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2005'
 GO
 
 
 -- Create a View with the BARRO_URSUA Indexed GDP in it

BEGIN TRY
DROP VIEW [dbo].[Barro_Ursua_Indexed_gdp]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Barro_Ursua_Indexed_gdp]
AS
-- Prepare to De-index GDP
SELECT 
 [SourceName],
 N'COPY OF GDP INDEXED' AS IndicatorStandardCode,
 [DimGeoID],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='BARRO-URSUA' and [FactQuery].IndicatorStandardCode='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2006'
 GO
 
-- Create a View with MADDISON:Population in it

BEGIN TRY
DROP VIEW [dbo].[Maddison_Population]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Maddison_Population]
AS

SELECT 
 [SourceName],
 N'COPY OF MADDISON:POPULATION' AS IndicatorStandardCode,
 [DimGeoID],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='MADDISON' and [FactQuery].IndicatorStandardCode='Population'
 GO
 
-- [WDI2018_2005_REALGDP_BASE]contains, for each GeoID, the real GDP per capita taken from 
-- WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2005] (the base year for the MACROHIST:rgdppc index)
 
BEGIN TRY
DROP VIEW [dbo].[WDI2018_2005_REALGDP_BASE]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[WDI2018_2005_REALGDP_BASE]
AS
 -- Select only year 2005 and the GeoID. As before, select GeoStandardName so we can see what's going on
SELECT
 [DimGeoID],
 N'COPY OF WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2005' AS IndicatorStandardCode,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='WDI2018' 
 AND [FactQuery].IndicatorStandardCode='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND [FactQuery].Year=2005
GO
 
 
-- [WDI2018_2006_REALGDP_BASE]contains, for each GeoID, the real GDP per capita taken from 
-- WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2006] (the base year for the MACROHIST:rgdppc index)
 
BEGIN TRY
DROP VIEW [dbo].[WDI2018_2006_REALGDP_BASE]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[WDI2018_2006_REALGDP_BASE]
AS
 -- Select only year 2006 and the GeoID. As before, select GeoStandardName so we can see what's going on
SELECT
 [DimGeoID],
 N'COPY OF WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2006' AS IndicatorStandardCode,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='WDI2018' 
 AND [FactQuery].IndicatorStandardCode='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND [FactQuery].Year=2006
GO
 
-- [Macrohist_WDI2018_Deindexed] uses [Macrohist_indexed] and [WDI2018_2005_REALGDP_BASE] to construct a de-indexed rgdppc

BEGIN TRY
DROP VIEW [dbo].[Macrohist_WDI2018_Deindexed]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Macrohist_WDI2018_Deindexed]
AS
SELECT 
 dbo.Macrohist_Indexed_rgdppc.DimGeoID,
 dbo.Macrohist_Indexed_rgdppc.IndicatorStandardCode, 
 dbo.Macrohist_Indexed_rgdppc.YearAsDate,
 dbo.Macrohist_Indexed_rgdppc.Value AS [Index],
 dbo.WDI2018_2005_REALGDP_BASE.Value AS Base,
 dbo.Macrohist_Indexed_rgdppc.Value*dbo.WDI2018_2005_REALGDP_BASE.Value/100 as Value
FROM dbo.Macrohist_Indexed_rgdppc LEFT OUTER JOIN
  dbo.WDI2018_2005_REALGDP_BASE ON 
  dbo.WDI2018_2005_REALGDP_BASE.DimGeoID = dbo.Macrohist_Indexed_rgdppc.DimGeoID
GO

-- [BARRO-URSUA_WDI2018_Deindexed] uses [Barro_Ursua_Indexed_gdp] and [WDI2018_2006_REALGDP_BASE] to construct a de-indexed rgdppc

BEGIN TRY
DROP VIEW [dbo].[BARRO_URSUA_WDI2018_Deindexed]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[BARRO_URSUA_WDI2018_Deindexed]
AS
SELECT 
 dbo.Barro_Ursua_Indexed_gdp.DimGeoID,
 dbo.Barro_Ursua_Indexed_gdp.IndicatorStandardCode, 
 dbo.Barro_Ursua_Indexed_gdp.YearAsDate,
 dbo.Barro_Ursua_Indexed_gdp.Value AS [Index],
 dbo.WDI2018_2006_REALGDP_BASE.Value AS Base,
 dbo.Barro_Ursua_Indexed_gdp.Value*dbo.WDI2018_2006_REALGDP_BASE.Value/100 as Value
FROM dbo.Barro_Ursua_Indexed_gdp LEFT OUTER JOIN
  dbo.WDI2018_2006_REALGDP_BASE ON 
  dbo.WDI2018_2006_REALGDP_BASE.DimGeoID = dbo.Barro_Ursua_Indexed_gdp.DimGeoID
GO

-- [Macrohist_extended] uses [Macrohist_WDI2018_Deindexed] and Macrohist itself to construct [Macrohist_WDI2018_rgdp]

BEGIN TRY
DROP VIEW [dbo].[Macrohist_extended]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Macrohist_extended]
AS
SELECT 
 N'MACROHIST' AS SourceName,
 N'MACROHIST-EXTENDED' AS DefinitionName,
 dbo.Macrohist_WDI2018_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS IndicatorStandardCode,
 dbo.Macrohist_WDI2018_Deindexed.YearAsDate,
 dbo.Maddison_Population.Value*Macrohist_WDI2018_Deindexed.Value as Value
FROM dbo.Macrohist_WDI2018_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.YearAsDate=Macrohist_WDI2018_Deindexed.YearAsDate AND
  dbo.Maddison_Population.DimGeoID=Macrohist_WDI2018_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.IndicatorStandardCode='GDP-TOTAL-LCU-CONSTANT2010'
GO

-- [Barro_Ursua_extended] uses Barro_Ursua_WDI2018_Deindexed] and Barro_Ursua itself to construct [Barro_Ursua_WDI2018_rgdp]

BEGIN TRY
DROP VIEW [dbo].[Barro_Ursua_extended]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Barro_Ursua_extended]
AS
SELECT 
 N'BARRO-URSUA' AS SourceName,
 N'BARRO-URSUA-EXTENDED' AS DefinitionName,
 dbo.Barro_Ursua_WDI2018_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS IndicatorStandardCode,
 dbo.Barro_Ursua_WDI2018_Deindexed.YearAsDate,
 dbo.Maddison_Population.Value*Barro_Ursua_WDI2018_Deindexed.Value as Value
FROM dbo.Barro_Ursua_WDI2018_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.YearAsDate=Barro_Ursua_WDI2018_Deindexed.YearAsDate AND
  dbo.Maddison_Population.DimGeoID=Barro_Ursua_WDI2018_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.IndicatorStandardCode='GDP-TOTAL-LCU-CONSTANT2010'
GO

-- APPEND THE NEW DEFINITIONS TO THE ADDED_DEFINITIONS TABLE
BEGIN TRY
DROP VIEW [dbo].[AddedDefinitions]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[AddedDefinitions]
AS
SELECT 
 [SourceName],
 [DefinitionName], 
 [DimGeoID],
 [DimIndicatorID],
 [YearAsDate],
 [Value]
FROM [dbo].[Macrohist_extended]
UNION
SELECT 
 [SourceName],
 [DefinitionName], 
 [DimGeoID],
 [DimIndicatorID],
 [YearAsDate],
 [Value]
FROM [dbo].[Barro_Ursua_extended]
GO

-- we have to now recover the indexes for source and definition before finally putting the result into the fact file.

BEGIN TRY
DROP VIEW [dbo].[NormalisedAddedDefinitions]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[NormalisedAddedDefinitions]
AS
SELECT
 [DimSourceID],
 [DimDefinitionID], 
 [DimGeoID],
 [DimIndicatorID],
 [YearAsDate],
 [Value]
FROM AddedDefinitions
INNER JOIN DimDefinitions ON
AddedDefinitions.DefinitionName=DimDefinitions.DefinitionName
INNER JOIN DimSource ON
AddedDefinitions.SourceName=DimSource.SourceName
GO

-- Finally insert all the new material into the fact file

INSERT INTO Fact(
 [DimSourceID],
 [DimDefinitionID], 
 [DimGeoID],
 [DimIndicatorID],
 [YearAsDate],
 [Value])
SELECT
 [DimSourceID],
 [DimDefinitionID], 
 [DimGeoID],
 [DimIndicatorID],
 [YearAsDate],
 [Value]
FROM NormalisedAddedDefinitions
GO 
 


 