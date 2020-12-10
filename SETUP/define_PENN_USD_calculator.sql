USE macrohistory_oltp
GO
-- Add USD measures for the PENN series
-- Do it here for convenience rather than oblige the user to write complex
-- DAX or MDX Queries
-- create temporary tables so we can inspect them to see what goes on, in case of problems

DROP TABLE IF EXISTS Temp_PENN_USD_Table 
GO 

-- xr2 is PENN's series code for 'Exchange rate, national currency/USD (market+estimated)'
-- xr (which we don't use) is their code for 'Exchange rate, national currency/USD (market)'
-- v_gdp is their code for GDP at current national prices.


SELECT
   dbo.RecognisedFacts.SourceName,
   dbo.RecognisedFacts.GeoSourceName,
   N'xr2*v_gdp' as IndicatorSourceCode,
   RecognisedFacts_1.Value/RecognisedFacts.Value AS Value,
   dbo.RecognisedFacts.Date INTO Temp_PENN_USD_Table 
FROM
   dbo.RecognisedFacts 
   LEFT OUTER JOIN
      dbo.RecognisedFacts AS RecognisedFacts_1 
      ON dbo.RecognisedFacts.SourceName = RecognisedFacts_1.SourceName 
      AND dbo.RecognisedFacts.GeoSourceName = RecognisedFacts_1.GeoSourceName 
      and RecognisedFacts.Date = RecognisedFacts_1.Date 
WHERE
   (
      dbo.RecognisedFacts.SourceName = N'PENN National Accounts 2020'
   )
   AND 
   (
      -- PENN code for exchange rate
      dbo.RecognisedFacts.IndicatorSourceCode = N'xr2'
   )
   AND 
   (
      -- PENN code for GDP in LCU
      RecognisedFacts_1.IndicatorSourceCode = N'v_gdp'
   )
GO 

INSERT INTO
 FactSource (SourceName, GeoSourceName, IndicatorSourceCode, Date, Value) 
 SELECT
	SourceName,
	GeoSourceName,
	IndicatorSourceCode,
	Date,
	Value 
 FROM
	Temp_PENN_USD_Table 
GO
