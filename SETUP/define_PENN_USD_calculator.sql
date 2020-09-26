USE macrohistory_oltp
GO
-- Add USD series for the various  PENN series
-- Do it here for convenience rather than oblige the user to write complex
-- DAX or MDX Queries
-- create temporary tables so we can inspect them to see what goes on, in case of problems

DROP TABLE IF EXISTS Temp_PENN_USD_Table 
GO 

SELECT
   dbo.RecognisedFacts.SourceName,
   dbo.RecognisedFacts.GeoSourceName,
   N'xr2*v_gdp' as IndicatorSourceCode,
   dbo.RecognisedFacts.Value*RecognisedFacts_1.Value AS Value,
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
      dbo.RecognisedFacts.SourceName = N'PENN'
   )
   AND 
   (
      dbo.RecognisedFacts.IndicatorSourceCode = N'xr2'
   )
   AND 
   (
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
