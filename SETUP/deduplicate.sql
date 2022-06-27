USE macrohistory_oltp_220522
GO

DROP TABLE IF EXISTS UN_duplicates

-- Select all UN2018 GDP that are duplicated for 'former' entities, but only for the years concerned
SELECT
 OLTP_FactID,
 SourceName,
 GeoSourceName,
 IndicatorSourceCode,
 Date,
 Value
INTO UN_duplicates
FROM FactSource
 WHERE FactSource.SourceName='UN2018' AND 
(FactSource.IndicatorSourceCode ='LCU-CURRENT.1' OR
 FactSource.IndicatorSourceCode=N'LCU-CURRENT.2' OR
 FactSource.IndicatorSourceCode=N'LCU-CURRENT.3' OR
 FactSource.IndicatorSourceCode=N'LCU-CURRENT.4' OR
 FactSource.IndicatorSourceCode=N'LCU-CURRENT.5' OR
 FactSource.IndicatorSourceCode=N'LCU-CURRENT.9' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.1' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.2' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.3' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.4' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.5' OR
 FactSource.IndicatorSourceCode=N'USD-CONSTANT.9' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.1' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.2' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.3' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.4' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.5' OR
 FactSource.IndicatorSourceCode=N'USD-CURRENT.9'
)
AND
 (
  (Year(Date)= 1990) AND (GeoSourceName= 'Former USSR')
  OR 
  (Year(Date)= 1990) AND (GeoSourceName='Former Yugoslavia')
  OR
  (Year(Date)>= 1990 and Year(date)<=1993) AND (GeoSourceName='Former Ethiopia')
  OR
  (Year(Date)= 1990) AND (GeoSourceName='Former Czechoslovakia')
 )
GO

DELETE FROM FactSource
WHERE FactSource.OLTP_FactID in (Select OLTP_FactID from UN_duplicates)

