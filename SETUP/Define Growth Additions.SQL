-- Create a view which reduces the year by one, to use in calculating annual growth
-- As of 29 November 2019 not used, but code kept in case useful
-- This work should now be done using DAX

BEGIN TRY 
DROP VIEW [dbo].[DeltaBackOne] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[DeltaBackOne]
AS
SELECT 
 DimSourceID,
 DimDefinitionID,
 DimGeoID,
 DimIndicatorID,
 SourceName,
 DefinitionName,
 GeoStandardName,
 indicatorStandardName,
 Value,
 YearAsDate as ThisYearAsDate,
 DATEADD(yyyy, - 1, YearAsDate) AS LastYearAsDate
FROM dbo.FactQuery
WHERE  dbo.FactQuery.[Add Calculated Growth]='Yes'
GO

-- query to extract growth
BEGIN TRY 
DROP VIEW [dbo].[Growth] 
END TRY 
BEGIN CATCH
END CATCH
GO

 -- query to extract growth
CREATE VIEW [dbo].[Growth]
AS
SELECT
 dbo.FactQuery.SourceName,
 DeltaBackOne.SourceName as DeltaSourceName,
 N'CLEANED' as NewDefinitionName,
 DeltaBackOne.DefinitionName as DeltaDefinitionName,
 dbo.FactQuery.indicatorStandardName,
 DeltaBackOne.indicatorStandardName+N'-GROWTH' as DeltaindicatorStandardName,
 dbo.FactQuery.YearAsDate, 
 DeltaBackOne.LastYearAsDate,
 DeltaBackOne.ThisYearAsDate,
 dbo.FactQuery.GeoStandardName,
 DeltaBackOne.GeoStandardName as DeltaGeoStandardName,
 dbo.FactQuery.DimGeoID,
 dbo.FactQuery.DimSourceID,
 dbo.FactQuery.DimIndicatorID,
	Case
	 when FactQuery.value is NULL
	 THEN NULL
	 when FactQuery.Value=0
	 THEN NULL
	 ELSE 
	 dbo.DeltaBackOne.Value/ dbo.FactQuery.Value  - 1
	END 
AS growth
FROM dbo.FactQuery INNER JOIN
 dbo.DeltaBackOne ON
 dbo.FactQuery.YearAsDate = dbo.DeltaBackOne.LastYearAsDate AND 
 dbo.FactQuery.DimSourceID = dbo.DeltaBackOne.DimSourceID AND 
 dbo.FactQuery.DimDefinitionID = dbo.DeltaBackOne.DimDefinitionID AND
 dbo.FactQuery.DimIndicatorID=dbo.DeltaBackOne.DimIndicatorID AND
 dbo.FactQuery.DimGeoID=DeltaBackOne.DimGeoID
GO 

-- query to prepare new growth records for insertion into Fact table 
BEGIN TRY 
DROP VIEW [dbo].[GrowthInserter] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[GrowthInserter]
AS
SELECT
 dbo.DimDefinitions.DimDefinitionID,
 dbo.Growth.DimGeoID,
 dbo.Growth.DimSourceID,
 dbo.DimIndicator.DimIndicatorID,
 dbo.Growth.growth AS Value,
 dbo.Growth.ThisYearAsDate
FROM dbo.Growth INNER JOIN
 dbo.DimDefinitions ON
 dbo.Growth.NewDefinitionName = dbo.DimDefinitions.DefinitionName INNER JOIN
 dbo.DimIndicator ON
 dbo.DimIndicator.indicatorStandardName=Growth.DeltaindicatorStandardName
GO
-- Now insert the growth definitions

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
 ThisYearAsDate,
 [Value]
FROM GrowthInserter
GO  