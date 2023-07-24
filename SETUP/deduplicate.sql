USE macrohistory_oltp_230505
GO

DROP TABLE IF EXISTS UN_duplicates

-- Select all UN 2023 GDP that are duplicated for 'former' entities, but only for the years concerned
SELECT
 OLTP_FactID,
 SourceName,
 GeoSourceName,
 IndicatorSourceCode,
 Date,
 Value
INTO UN_duplicates
FROM FactSource
 WHERE (FactSource.SourceName='UN2023-USD-GDP-SECTORS' OR FactSource.SourceName='UN2023-POPULATION')

AND
 (
  (Year(Date)= 1990) AND (GeoSourceName= 'USSR (Former')
  OR 
  (Year(Date)= 1990) AND (GeoSourceName='Yugoslavia (Former')
  OR
  (Year(Date)>= 1990 and Year(date)<=1993) AND (GeoSourceName='Ethiopia (Former)')
  OR
  (Year(Date)= 1990) AND (GeoSourceName='Czechoslovakia (Former)')
 )
GO

DELETE FROM FactSource
WHERE FactSource.OLTP_FactID in (Select OLTP_FactID from UN_duplicates)

