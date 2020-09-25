/* The queries below create four CLEANED Definitions:

 MACROHIST:rgdppc_deindexed reconstructs GDP per capita from MACROHIST:rgdppc, which is indexed to the year 2005,
 by multiplying it by WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2005].
 
 MACROHIST:rgdp multiplies this by popularion to obtain a long real GDP series calibrated with 
 WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT for the years above 1960
 
 BARRO_URSUA:gdp_deindexed reconstructs GDP per capita from BARRO_URSUA:GDP per Capita, 2006=100 which is indexed to the year 2006,
 by multiplying it by WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT[@2006].
 
 BARRO_URSUA:gdp multiplies this by MACROHIST:pop to obtain a long real GDP series calibrated with 
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
 N'COPY OF RGDPPC INDEXED' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='MACROHIST' and [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2005'
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
 N'COPY OF GDP INDEXED' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='BARRO-URSUA' and [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT-INDEXED-2006'
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
 N'COPY OF MADDISON:POPULATION' AS indicatorStandardName,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='MADDISON' and [FactQuery].indicatorStandardName='Population'
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
 N'COPY OF WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2005' AS indicatorStandardName,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].SourceName='WDI2018' 
 AND [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND Year([FactQuery].DateField)=2005
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
 N'COPY OF WDI2018:GDP-TOTAL-PERCAPITA-LCU-CONSTANT FOR YEAR 2006' AS indicatorStandardName,
 [Value]
 FROM [FactQuery]
 WHERE [FactQuery].SourceName='WDI2018' 
 AND [FactQuery].indicatorStandardName='GDP-TOTAL-PERCAPITA-LCU-CONSTANT' 
 AND Year([FactQuery].DateField)=2006
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
 dbo.Macrohist_Indexed_rgdppc.indicatorStandardName, 
 dbo.Macrohist_Indexed_rgdppc.DateField,
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
 dbo.Barro_Ursua_Indexed_gdp.indicatorStandardName, 
 dbo.Barro_Ursua_Indexed_gdp.DateField,
 dbo.Barro_Ursua_Indexed_gdp.Value AS [Index],
 dbo.WDI2018_2006_REALGDP_BASE.Value AS Base,
 dbo.Barro_Ursua_Indexed_gdp.Value*dbo.WDI2018_2006_REALGDP_BASE.Value/100 as Value
FROM dbo.Barro_Ursua_Indexed_gdp LEFT OUTER JOIN
  dbo.WDI2018_2006_REALGDP_BASE ON 
  dbo.WDI2018_2006_REALGDP_BASE.DimGeoID = dbo.Barro_Ursua_Indexed_gdp.DimGeoID
GO

-- use [Macrohist_WDI2018_Deindexed] and Macrohist itself to construct [Macrohist_WDI2018_rgdp]

BEGIN TRY
DROP VIEW [dbo].[Macrohist_cleaner]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Macrohist_cleaner]
AS
SELECT 
 N'MACROHIST' AS SourceName,
 N'CLEANED' AS DefinitionName,
 dbo.Macrohist_WDI2018_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS indicatorStandardName,
 dbo.Macrohist_WDI2018_Deindexed.DateField,
 dbo.Maddison_Population.Value*Macrohist_WDI2018_Deindexed.Value as Value
FROM dbo.Macrohist_WDI2018_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.DateField=Macrohist_WDI2018_Deindexed.DateField AND
  dbo.Maddison_Population.DimGeoID=Macrohist_WDI2018_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.indicatorStandardName='GDP-TOTAL-LCU-CONSTANT2010'
GO

-- [Barro_Ursua_cleaner] uses Barro_Ursua_WDI2018_Deindexed] and Barro_Ursua itself to construct [Barro_Ursua_WDI2018_rgdp]

BEGIN TRY
DROP VIEW [dbo].[Barro_Ursua_cleaner]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[Barro_Ursua_cleaner]
AS
SELECT 
 N'BARRO-URSUA' AS SourceName,
 N'CLEANED' AS DefinitionName,
 dbo.Barro_Ursua_WDI2018_Deindexed.DimGeoID,
 dbo.DimIndicator.DimIndicatorID,
 N'GDP-TOTAL-LCU-CONSTANT2010' AS indicatorStandardName,
 dbo.Barro_Ursua_WDI2018_Deindexed.DateField,
 dbo.Maddison_Population.Value*Barro_Ursua_WDI2018_Deindexed.Value as Value
FROM dbo.Barro_Ursua_WDI2018_Deindexed LEFT OUTER JOIN
  dbo.Maddison_Population ON
  dbo.Maddison_Population.DateField=Barro_Ursua_WDI2018_Deindexed.DateField AND
  dbo.Maddison_Population.DimGeoID=Barro_Ursua_WDI2018_Deindexed.DimGeoID
 LEFT OUTER JOIN
  dbo.DimIndicator ON
  dbo.DimIndicator.indicatorStandardName='GDP-TOTAL-LCU-CONSTANT2010'
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
 [DateField],
 [Value]
FROM [dbo].[Macrohist_cleaner]
UNION
SELECT 
 [SourceName],
 [DefinitionName], 
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM [dbo].[Barro_Ursua_cleaner]
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
 [DateField],
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
 [DateField],
 [Value])
SELECT
 [DimSourceID],
 [DimDefinitionID], 
 [DimGeoID],
 [DimIndicatorID],
 [DateField],
 [Value]
FROM NormalisedAddedDefinitions
GO 
 


 