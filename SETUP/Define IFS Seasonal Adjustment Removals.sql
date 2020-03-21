USE [ROLAP]

-- Create a temporary definition table
-- create the seasonal adjustment view

BEGIN TRY
DROP VIEW [dbo].[IFSSeasonalAdjustmentRemoval]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [IFSSeasonalAdjustmentRemoval]
AS
-- Select all GDP-USD-CURRENT from IFS before 1970 (not present in UN2018)
SELECT
 [DimSourceID],
  N'CLEANED' as DefinitionName, 
 [DimGeoID],
  N'GDP-TOTAL-USD-CURRENT' AS IndicatorStandardName,
 [YearAsDate],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'IFS2018') 
	and [FactQuery].IndicatorStandardName='GDP-TOTAL-USD-CURRENT'
-- for UK and former colonies, and Mexico, use the seasonally-adjusted series, which goes back further in time
	and [FactQuery].GeoStandardName!='United States'
	and [FactQuery].GeoStandardName!='Australia'
	and [FactQuery].GeoStandardName!='United Kingdom'
	and [FactQuery].GeoStandardName!='Canada'
	and [FactQuery].GeoStandardName!='New Zealand'
	and [FactQuery].GeoStandardName!='Mexico'
UNION
SELECT
 [DimSourceID],
  N'CLEANED' as DefinitionName, 
 [DimGeoID],
  N'GDP-TOTAL-USD-CURRENT' AS IndicatorStandardName,
 [YearAsDate],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'IFS2018') 
	and [FactQuery].IndicatorStandardName='GDP-TOTAL-USD-CURRENT-SA'
	and (
-- for UK and former colonies, and Mexico, use the seasonally-adjusted series, which goes back further in time
	[FactQuery].GeoStandardName='United States'
	or [FactQuery].GeoStandardName='Australia'
	or [FactQuery].GeoStandardName='United Kingdom'
	or [FactQuery].GeoStandardName='Canada'
	or [FactQuery].GeoStandardName='New Zealand'
	or [FactQuery].GeoStandardName='Mexico')
GO

-- locate the IndicatorID and DefinitionID for the seasonal adjustment corrector

BEGIN TRY
DROP VIEW [dbo].[IFSSeasonalAdjustmentRemoval_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [IFSSeasonalAdjustmentRemoval_KeyFinder]
AS
SELECT
 IFSSeasonalAdjustmentRemoval.DimSourceID,
 DimDefinitions.DimDefinitionID,
 IFSSeasonalAdjustmentRemoval.DimGeoID,
 DimIndicator.DimIndicatorID,
 YearAsDate,
 Value
FROM [IFSSeasonalAdjustmentRemoval] INNER JOIN DimIndicator ON
 DimIndicator.IndicatorStandardName=IFSSeasonalAdjustmentRemoval.IndicatorStandardName
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=IFSSeasonalAdjustmentRemoval.DefinitionName
GO

-- Insert into the fact file
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
 YearAsDate,
 [Value]
FROM IFSSeasonalAdjustmentRemoval_KeyFinder
GO 
