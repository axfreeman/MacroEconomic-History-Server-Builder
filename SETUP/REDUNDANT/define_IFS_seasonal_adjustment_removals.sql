USE macrohistory_rolap
go
-- This script normalises the anomalous IFS series for current USD covering USA, Australia, United Kingdom, Canada, New Zealand and Mexico
-- the IFS provides seasonally adjusted series for these which go further back in time.
-- the script therefore renames these series to be unadjusted, since with annual data, the distinction creates unnecessary complications
-- and deletes the unadjusted series

-- create seasonal adjustment view
CREATE OR ALTER VIEW [IFSSeasonalAdjustmentRemoval]
AS
-- Select all GDP-USD-CURRENT from IFS before 1970 (not present in UN2018)
SELECT
 [DimSourceID],
 [DimGeoID],
  N'GDP-TOTAL-USD-CURRENT' AS IndicatorStandardName,
 [DateField],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'IFS2020') 
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
 [DimGeoID],
  N'GDP-TOTAL-USD-CURRENT' AS IndicatorStandardName,
 [DateField],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'IFS2020') 
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

-- Create a temporary definition table to hold the results

SELECT * INTO 
IFS_temporary_seasonal_adjustment_table
FROM IFSSeasonalAdjustmentRemoval 

-- delete the original entries

DELETE FROM FactQuery
WHERE 
	([FactQuery].SourceName = N'IFS2020') 
	and [FactQuery].IndicatorStandardName='GDP-TOTAL-USD-CURRENT'
	and [FactQuery].GeoStandardName!='United States'
	and [FactQuery].GeoStandardName!='Australia'
	and [FactQuery].GeoStandardName!='United Kingdom'
	and [FactQuery].GeoStandardName!='Canada'
	and [FactQuery].GeoStandardName!='New Zealand'
	and [FactQuery].GeoStandardName!='Mexico'

GO

DELETE FROM FactQuery
WHERE
	([FactQuery].SourceName = N'IFS2020') 
	and [FactQuery].IndicatorStandardName='GDP-TOTAL-USD-CURRENT-SA'
	and (
	[FactQuery].GeoStandardName='United States'
	or [FactQuery].GeoStandardName='Australia'
	or [FactQuery].GeoStandardName='United Kingdom'
	or [FactQuery].GeoStandardName='Canada'
	or [FactQuery].GeoStandardName='New Zealand'
	or [FactQuery].GeoStandardName='Mexico')
GO

-- Construct a view to find the dimension IDs for the seasonal adjustment corrector
CREATE OR ALTER VIEW [IFSSeasonalAdjustmentRemoval_KeyFinder]
AS
SELECT
 IFS_temporary_seasonal_adjustment_table.DimSourceID,
 IFS_temporary_seasonal_adjustment_table.DimGeoID,
 DimIndicator.DimIndicatorID,
 DateField,
 Value
FROM [IFS_temporary_seasonal_adjustment_table] INNER JOIN DimIndicator ON
 DimIndicator.IndicatorStandardName=IFS_temporary_seasonal_adjustment_table.IndicatorStandardName

GO

-- Insert into the fact file
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
 DateField,
 [Value]
FROM IFSSeasonalAdjustmentRemoval_KeyFinder
GO 
