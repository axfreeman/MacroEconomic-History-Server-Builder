USE MACROHISTORY_OLTP_220522
GO
-- Add USD series for the IFS GDP and SAGDP series
-- Do it here for convenience rather than oblige the user to write complex
-- DAX or MDX Queries
-- create temporary tables so we can inspect them to see what goes on, in case of problems

DROP TABLE IF EXISTS Temp_IFS_USD_Table 
GO 

-- Construct a table containing the USD GDP for the non-seasonally-adjusted series
SELECT
   dbo.RecognisedFacts.SourceName,
   dbo.RecognisedFacts.GeoSourceName,
   N'NGDP_XDC*EDNA_USD_XDC_RATE' as IndicatorSourceCode,
   dbo.RecognisedFacts.Value*RecognisedFacts_1.Value AS Value,
   dbo.RecognisedFacts.Date INTO Temp_IFS_USD_Table 
FROM
   dbo.RecognisedFacts 
   LEFT OUTER JOIN
      dbo.RecognisedFacts AS RecognisedFacts_1 
      ON dbo.RecognisedFacts.SourceName = RecognisedFacts_1.SourceName 
      AND dbo.RecognisedFacts.GeoSourceName = RecognisedFacts_1.GeoSourceName 
      and RecognisedFacts.Date = RecognisedFacts_1.Date 
WHERE
   (
      dbo.RecognisedFacts.SourceName = N'IFS2020'
   )
   AND 
   (
      -- GDP in LCU
      dbo.RecognisedFacts.IndicatorSourceCode = N'NGDP_XDC'
   )
   AND 
   (
      -- Exchange rate
      RecognisedFacts_1.IndicatorSourceCode = N'EDNA_USD_XDC_RATE'
   )
GO 

-- Construct a table containing the USD GDP for seasonally-adjusted series
DROP TABLE IF EXISTS Temp_IFS_USD_SA_Table 
   SELECT
      dbo.RecognisedFacts.SourceName,
      dbo.RecognisedFacts.GeoSourceName,
      N'NGDP_XDC_SA*EDNA_USD_XDC_RATE' as IndicatorSourceCode,
      dbo.RecognisedFacts.Value*RecognisedFacts_1.Value AS Value,
      dbo.RecognisedFacts.Date INTO Temp_IFS_USD_SA_Table 
   FROM
      dbo.RecognisedFacts 
      LEFT OUTER JOIN
         dbo.RecognisedFacts AS RecognisedFacts_1 
         ON dbo.RecognisedFacts.SourceName = RecognisedFacts_1.SourceName 
         AND dbo.RecognisedFacts.GeoSourceName = RecognisedFacts_1.GeoSourceName 
         and RecognisedFacts.Date = RecognisedFacts_1.Date 
   WHERE
      (
         dbo.RecognisedFacts.SourceName = N'IFS2020'
      )
      AND 
      (
         -- Seasonally adjusted GDP in LCU (where this exists)
         dbo.RecognisedFacts.IndicatorSourceCode = N'NGDP_SA_XDC'
      )
      AND 
      (
         -- Exchange rate
         RecognisedFacts_1.IndicatorSourceCode = N'EDNA_USD_XDC_RATE'
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
		Temp_IFS_USD_Table 
   INSERT INTO
	  FactSource (SourceName, GeoSourceName, IndicatorSourceCode, Date, Value) 
	  SELECT
		 SourceName,
		 GeoSourceName,
		 IndicatorSourceCode,
		 Date,
		 Value 
	  FROM
		 Temp_IFS_USD_SA_Table
GO
