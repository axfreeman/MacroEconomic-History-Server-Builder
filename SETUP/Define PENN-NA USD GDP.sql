USE [ROLAP]

-- Create the exchange rate table

BEGIN TRY
DROP VIEW [dbo].[PENN_ExchangeRates]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [PENN_ExchangeRates]
AS
-- Select all GDP-USD-CURRENT from PENN
SELECT
 [DimSourceID],
  N'CLEANED' as DefinitionName, 
 [DimGeoID],
  N'EXCHANGE_RATE_TEMP' AS IndicatorStandardCode,
 [YearAsDate],
 [Value]
 FROM [FactQuery]
	WHERE 
	([FactQuery].SourceName = N'PENN') 
	and [FactQuery].IndicatorStandardCode='EXCHANGE-RATE-LCUperUSD-PENNMARKET+ESTIMATE'
GO

-- Join with LCU-CURRENT and divide to get USD-CURRENT

BEGIN TRY
DROP VIEW [dbo].[PENN_USD_Calculated]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [PENN_USD_Calculated]
AS
SELECT
 [FactQuery]. [DimSourceID],
  N'CLEANED' as DefinitionName, 
  N'GDP-TOTAL-USD-CURRENT' AS IndicatorStandardCode,
 [FactQuery].[DimGeoID],
 [FactQuery].[YearAsDate],
 [FactQuery].[Value]/[PENN_ExchangeRates].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [PENN_ExchangeRates] ON
 FactQuery.DimGeoID=PENN_ExchangeRates.DimGeoID AND
 FactQuery.YearAsDate=PENN_ExchangeRates.YearAsDate 
	WHERE 
	[FactQuery].IndicatorStandardCode='GDP-TOTAL-LCU-CURRENT' AND
	[FactQuery].SourceName='PENN'
GO

BEGIN TRY
DROP VIEW [dbo].[PENN_USD_Calculated_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO


CREATE VIEW [PENN_USD_Calculated_KeyFinder]
AS
SELECT
 PENN_USD_Calculated.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 YearAsDate,
 Value
FROM [PENN_USD_Calculated] INNER JOIN DimIndicator ON
 DimIndicator.IndicatorStandardCode=PENN_USD_Calculated.IndicatorStandardCode
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=PENN_USD_Calculated.DefinitionName
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
FROM PENN_USD_Calculated_KeyFinder
GO 
