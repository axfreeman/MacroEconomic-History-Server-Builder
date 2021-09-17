USE macrohistory_rolap
GO
/* This query creates the World Indquality Database (WID) transformations:
	1) Calculate NDP and NI in USD (NB for countries, not reporting units)
	2) Calculate National Income (NDP+Foreign Income) in LCU
	3) Calculate National Income in USD
	4) Calculate Foreign Income in USD
*/


--(1) Calculate NDP and NI in USD (NB for countries, not reporting units)
-- Create a view with exchange rates in it

CREATE OR ALTER VIEW [PENN_ExchangeRates]
AS
SELECT
 [DimSourceID],
  N'WID-EXTENDED' as DefinitionName, 
 [DimGeoID],
  N'EXCHANGE_RATE_TEMP' AS indicatorstandardname,
 [DateField],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'PENN') 
	and [FactQuery].indicatorstandardname='EXCHANGE-RATE-LCUperUSD-PENNMARKET+ESTIMATE'
	and Year([DateField])<=2014

--IFS does not take care of Euro currencies before Eurification	
	
UNION
SELECT
 [DimSourceID],
  N'WID-EXTENDED' as DefinitionName, 
 [DimGeoID],
  N'EXCHANGE_RATE_TEMP' AS indicatorstandardname,
 [DateField],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].DefinitionName = N'IFS2018') 
	and [FactQuery].indicatorstandardname='EXCHANGE-RATE-LCUperUSD-PERIODAVERAGE'
	and Year([DateField])>2014

	
GO


BEGIN TRY
DROP VIEW [dbo].[WID_NDP_USD_Calculated]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [WID_NDP_USD_Calculated]
AS
SELECT
 [FactQuery]. [DimSourceID],
  N'WID-EXTENDED' as DefinitionName, 
  N'GDP-NET-TOTAL-USD-CURRENT' AS indicatorstandardname,
 [FactQuery].[DimGeoID],
 [FactQuery].[DateField],
 [FactQuery].[Value]/[PENN_ExchangeRates].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [PENN_ExchangeRates] ON
 FactQuery.DimGeoID=PENN_ExchangeRates.DimGeoID AND
 FactQuery.DateField=PENN_ExchangeRates.DateField 
	WHERE 
	[FactQuery].indicatorstandardname='GDP-NET-TOTAL-LCU-CURRENT' AND
	[FactQuery].DefinitionName='WID-EXTENDED'
GO


BEGIN TRY
DROP VIEW [dbo].[WID_USD_Calculated_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO


CREATE VIEW [WID_USD_Calculated_KeyFinder]
AS
SELECT
 WID_NDP_USD_Calculated.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 DateField,
 Value
FROM [WID_NDP_USD_Calculated] INNER JOIN DimIndicator ON
 WID_NDP_USD_Calculated.indicatorstandardname=DimIndicator.indicatorstandardname
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=WID_NDP_USD_Calculated.DefinitionName
GO


-- Insert into the fact file
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
 DateField,
 [Value]
FROM WID_USD_Calculated_KeyFinder
GO 

-- (2) Calculate National Income (NDP+Income Transfers)
-- Create a View with NDP in it

BEGIN TRY
DROP VIEW [dbo].[WID_National_Income]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[WID_National_Income]
AS
SELECT 
 [SourceName],
 N'COPY OF WID NDP' AS indicatorstandardname,
 [DimGeoID],
 [DateField],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='WID-EXTENDED' and [FactQuery].indicatorstandardname='GDP-NET-TOTAL-LCU-CURRENT'
 GO
 
-- Add it to foreign income

BEGIN TRY
DROP VIEW [dbo].[WID_National_Income_Calculated]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [WID_National_Income_Calculated]
AS
SELECT
 [FactQuery]. [DimSourceID],
  N'WID-EXTENDED' AS DefinitionName, 
  N'GDP-NATIONAL-INCOME-LCU-CURRENT' AS indicatorstandardname,
 [FactQuery].[DimGeoID],
 [FactQuery].[DateField],
 [FactQuery].[Value] + [WID_National_Income].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [WID_National_Income] ON
 FactQuery.DimGeoID=WID_National_Income.DimGeoID AND
 FactQuery.DateField=WID_National_Income.DateField 
	WHERE 
	[FactQuery].indicatorstandardname='GDP-FOREIGN-INCOME-LCU-CURRENT' AND
	[FactQuery].DefinitionName='WID'
GO 


BEGIN TRY
DROP VIEW [dbo].[WID_National_Income_Calculated_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO


CREATE VIEW [WID_National_Income_Calculated_KeyFinder]
AS
SELECT
 WID_National_Income_Calculated.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 DateField,
 Value
FROM [WID_National_Income_Calculated] INNER JOIN DimIndicator ON
 DimIndicator.indicatorstandardname=WID_National_Income_Calculated.indicatorstandardname
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=WID_National_Income_Calculated.DefinitionName
GO

-- Insert into the fact file
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
 DateField,
 [Value]
FROM WID_National_Income_Calculated_KeyFinder
GO 


-- (3) calculate USD national income
BEGIN TRY
DROP VIEW [dbo].[WID_National_Income_USD_Calculated]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [WID_National_Income_USD_Calculated]
AS
SELECT
 [FactQuery]. [DimSourceID],
  N'WID-EXTENDED' as DefinitionName, 
  N'GDP-NATIONAL-INCOME-USD-CURRENT' AS indicatorstandardname,
 [FactQuery].[DimGeoID],
 [FactQuery].[DateField],
 [FactQuery].[Value]/[PENN_ExchangeRates].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [PENN_ExchangeRates] ON
 FactQuery.DimGeoID=PENN_ExchangeRates.DimGeoID AND
 FactQuery.DateField=PENN_ExchangeRates.DateField 
	WHERE 
	[FactQuery].indicatorstandardname='GDP-NATIONAL-INCOME-LCU-CURRENT' AND
	[FactQuery].DefinitionName='WID-EXTENDED'
GO


BEGIN TRY
DROP VIEW [dbo].[WID_National_Income_USD_Calculated_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO


CREATE VIEW [WID_National_Income_USD_Calculated_KeyFinder]
AS
SELECT
 WID_National_Income_USD_Calculated.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 DateField,
 Value
FROM [WID_National_Income_USD_Calculated] INNER JOIN DimIndicator ON
 WID_National_Income_USD_Calculated.indicatorstandardname=DimIndicator.indicatorstandardname
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=WID_National_Income_USD_Calculated.DefinitionName
GO


-- Insert into the fact file
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
 DateField,
 [Value]
FROM WID_National_Income_USD_Calculated_KeyFinder
GO 

-- 4)Calculate Foreign Income USD separately

BEGIN TRY
DROP VIEW [dbo].[WID_Foreign_Income_USD_Calculated]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [WID_Foreign_Income_USD_Calculated]
AS
SELECT
 [FactQuery]. [DimSourceID],
  N'WID-EXTENDED' as DefinitionName, 
  N'GDP-FOREIGN-INCOME-USD-CURRENT' AS indicatorstandardname,
 [FactQuery].[DimGeoID],
 [FactQuery].[DateField],
 [FactQuery].[Value]/[PENN_ExchangeRates].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [PENN_ExchangeRates] ON
 FactQuery.DimGeoID=PENN_ExchangeRates.DimGeoID AND
 FactQuery.DateField=PENN_ExchangeRates.DateField 
	WHERE 
	[FactQuery].indicatorstandardname='GDP-FOREIGN-INCOME-LCU-CURRENT' AND
	[FactQuery].DefinitionName='WID'
GO


BEGIN TRY
DROP VIEW [dbo].[WID_Foreign_Income_USD_Calculated_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO


CREATE VIEW [WID_Foreign_Income_USD_Calculated_KeyFinder]
AS
SELECT
 WID_Foreign_Income_USD_Calculated.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 DateField,
 Value
FROM [WID_Foreign_Income_USD_Calculated] INNER JOIN DimIndicator ON
 WID_Foreign_Income_USD_Calculated.indicatorstandardname=DimIndicator.indicatorstandardname
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=WID_Foreign_Income_USD_Calculated.DefinitionName
GO


-- Insert into the fact file
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
 DateField,
 [Value]
FROM WID_Foreign_Income_USD_Calculated_KeyFinder
GO 