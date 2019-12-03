USE ROLAP
GO

-- Create the exchange rate view

CREATE OR ALTER VIEW [PENN_ExchangeRates]
AS
-- Select all Exchange Rates from PENN
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



BEGIN TRY
DROP FUNCTION [dbo].[PENN_USD_Calculated_fn]
END TRY
BEGIN CATCH
END CATCH
GO

-- Create a parameterised function which uses the exchange rate view to return a table
-- giving the current USD values of a given PENN Indicator specified in Current LCU

CREATE FUNCTION [PENN_USD_Calculated_fn] (@input_indicator varchar(100),@output_indicator varchar(100))
RETURNS TABLE 
AS
RETURN(
SELECT
 [FactQuery]. [DimSourceID],
  N'CLEANED' as DefinitionName, 
	-- eg   N'GDP-TOTAL-USD-CURRENT' 
  @output_indicator
AS IndicatorStandardCode,
 [FactQuery].[DimGeoID],
 [FactQuery].[YearAsDate],
 [FactQuery].[Value]/[PENN_ExchangeRates].[Value] as Value
 FROM [FactQuery]
 INNER JOIN [PENN_ExchangeRates] ON
 FactQuery.DimGeoID=PENN_ExchangeRates.DimGeoID AND
 FactQuery.YearAsDate=PENN_ExchangeRates.YearAsDate 
	WHERE 
		-- eg 'GDP-TOTAL-LCU-CURRENT'
	[FactQuery].IndicatorStandardCode=@input_indicator AND
	[FactQuery].SourceName='PENN'
)
GO

-- create this view once initially so that the keyfinder view (defined next) recognises its existence
-- this view will be recreated multiple times as we work through the indicators in the PENN table
-- but the keyfinder view does not need to be recreated each time
-- probably this could all be done in a more 'efficient' way, but the main criterion 
-- for design is to get the thing working, since we rebuild the database relatively infrequently

create or alter  view [dbo].[PENN_USD_TEMPORARY_TABLE]
AS
SELECT * FROM PENN_USD_Calculated_fn(N'GDP-TOTAL-USD-CURRENT','GDP-TOTAL-LCU-CURRENT')
GO

-- create a view which uses a temporary table containing converted USD values but without the indicator FK
-- into a table that does contain the indicator FK


CREATE OR ALTER VIEW [PENN_USD_Calculated_KeyFinder]
AS
SELECT
 PENN_USD_TEMPORARY_TABLE.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeoID,
 DimIndicator.DimIndicatorID,
 YearAsDate,
 Value
FROM PENN_USD_TEMPORARY_TABLE INNER JOIN DimIndicator ON
 DimIndicator.IndicatorStandardCode=PENN_USD_TEMPORARY_TABLE.IndicatorStandardCode
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=PENN_USD_TEMPORARY_TABLE.DefinitionName
GO

-- create a procedure to append to the fact file the view given by the keyfinder of the TEMOPORARY_TABLE created by calculated_fn
-- (phew)

create or alter procedure [dbo].[PENN_USD_Injector]
AS
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


