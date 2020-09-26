
UNION
-- Add the PENN data for Taiwan because UN omits it for political reasons only
SELECT 
 SourceName,
 GeoSourceName,
 DimIndicatorID,
 DateField,
 Value
FROM FactSource
 WHERE FactSource.SourceName='PENN' AND 
 (Year(DateField)>=1970) AND
 (GeoSourceName='Taiwan') AND
 (FactSource.IndicatorSourceCode='GDP-TOTAL-USD-CURRENT'
GO


DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_File.DateField)= 1990) 
AND (GeoSourceName='USSR')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1990) 
AND (GeoSourceName='Yugoslavia')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1990) 
AND (GeoSourceName='Ethiopia (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1991) 
AND (GeoSourceName='Ethiopia (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1992) 
AND (GeoSourceName='Ethiopia (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1993) 
AND (GeoSourceName='Ethiopia (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 1990) 
AND (GeoSourceName='Czechoslovakia (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 2008) 
AND (GeoSourceName='Sudan (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 2009) 
AND (GeoSourceName='Sudan (Former)')

DELETE FROM dbo.UN_TD_File 
WHERE (Year(UN_TD_FILE.DateField)= 2010) 
AND (GeoSourceName='Sudan (Former)')
GO
-- TODO: former Indonesia?
-- TODO: former Netherlands Antilles


CREATE OR ALTER VIEW dbo.MADDISON_RU_Corrector
AS
-- Select all MADDISON Records
SELECT 
 SourceName,
 GeoSourceName,
 ReportingUnit,
 DimIndicatorID,
 DateField,
 Year(DateField) as Year,
 Value
FROM FactSource
 WHERE FactSource.SourceName='MADDISON' 
GO

-- plonk the MADDISON definitions into a temporary file so we can edit out the duplicates
 
BEGIN TRY 
DROP TABLE dbo.MADDISON_TD_File 
END TRY 
BEGIN CATCH
END CATCH
GO

SELECT 
 SourceName,
 GeoSourceName,
 ReportingUnit,
 DimIndicatorID,
 DateField,
 Year(DateField) as Year,
 Value
INTO dbo.MADDISON_TD_File
 FROM MADDISON_RU_Corrector
GO
 
-- delete duplicated entries 

DELETE FROM dbo.MADDISON_TD_File 
WHERE 
(MADDISON_TD_File.GeoSourceName= 'Czech Republic') OR 
(MADDISON_TD_File.GeoSourceName= 'Slovak Republic')

-- delete duplicated USSR components

DELETE FROM dbo.MADDISON_TD_File 
WHERE 
(MADDISON_TD_File.ReportingUnit= 'USSR') AND
(MADDISON_TD_File.GeoSourceName <> 'USSR')
GO

CREATE OR ALTER VIEW dbo.MADDISON_RU_Corrector_KeyFinder
AS
SELECT
 MADDISON_TD_File.SourceName,
 DimGeo.DimGeoID,
 MADDISON_TD_File.DimIndicatorID,
 MADDISON_TD_File.DateField,
 MADDISON_TD_File.Value
FROM MADDISON_TD_File INNER JOIN DimGeo ON
 DimGeo.GeoSourceName=MADDISON_TD_File.GeoSourceName
GO


-- Insert into the fact file
INSERT INTO Fact(
 SourceName,
 DimGeoID,
 DimIndicatorID,
 DateField,
 Value)
SELECT
 SourceName,
 DimGeoID,
 DimIndicatorID,
 DateField,
 Value
FROM MADDISON_RU_Corrector_KeyFinder
GO 


-- WID

CREATE OR ALTER VIEW dbo.WID_RU_Corrector
AS
-- Select all WID Records
SELECT 
 SourceName,
 GeoSourceName,
 ReportingUnit,
 DimIndicatorID,
 IndicatorSourceCode,
 DateField,
 Year(DateField) as Year,
 Value
FROM FactSource
 WHERE FactSource.SourceName='WID'
  AND IndicatorSourceCode='GDP-NET-TOTAL-LCU-CURRENT'
  or IndicatorSourceCode='GDP-FOREIGN-INCOME-LCU'
GO

-- plonk the WID definitions into a temporary file so we can edit out the duplicates
 
BEGIN TRY 
DROP TABLE dbo.WID_TD_File 
END TRY 
BEGIN CATCH
END CATCH
GO

SELECT 
 SourceName,
 GeoSourceName,
 ReportingUnit,
 IndicatorSourceCode,
 DateField,
 Value
INTO dbo.WID_TD_File
 FROM WID_RU_Corrector
GO
 
-- delete duplicated entries for Czechoslovakia

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.GeoSourceName= 'Czechoslovakia (Former)')  AND
Year(DateField)=1990

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.GeoSourceName= 'Czech Republic')  AND
Year(DateField)=1992

-- delete duplicated USSR components

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.ReportingUnit= 'USSR') AND
(IndicatorSourceCode='GDP-NET-TOTAL-LCU-CURRENT')AND
(Year(DateField)<1990)

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.ReportingUnit= 'USSR') AND
(IndicatorSourceCode='GDP-FOREIGN-INCOME-LCU')AND
(Year(DateField)<2002)

-- delete duplicated Yugoslavia components

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.ReportingUnit= 'Yugoslavia') AND
(IndicatorSourceCode='GDP-FOREIGN-INCOME-LCU')AND
(Year(DateField)<2007)

-- Ethiopia 

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.GeoSourceName= 'Eritrea')

-- Indonesia

DELETE FROM dbo.WID_TD_File 
WHERE 
(WID_TD_File.GeoSourceName= 'Timor-Leste')


BEGIN TRY
DROP VIEW dbo.WID_RU_Corrector_KeyFinder
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW dbo.WID_RU_Corrector_KeyFinder
AS
SELECT
 WID_TD_File.SourceName,
 DimGeo.DimGeoID,
 DimIndicator.DimIndicatorID,
 WID_TD_File.DateField,
 WID_TD_File.Value
FROM WID_TD_File INNER JOIN DimGeo ON
 DimGeo.GeoSourceName=WID_TD_File.GeoSourceName
INNER JOIN DimIndicator ON
 DimIndicator.IndicatorSourceCode=WID_TD_File.IndicatorSourceCode 
GO


-- Insert into the fact file
INSERT INTO Fact(
 SourceName,
 DimGeoID,
 DimIndicatorID,
 DateField,
 Value)
SELECT
 SourceName,
 DimGeoID,
 DimIndicatorID,
 DateField,
 Value
FROM WID_RU_Corrector_KeyFinder
GO 



