USE ROLAP

-- Create the UN Corrector view
BEGIN TRY
DROP VIEW [dbo].[UN_RU_Corrector]
END TRY
BEGIN CATCH
END CATCH
GO

-- Select all UN2018 GDP and POPULATION
--Add the PENN data for Taiwan because UN omits it for political reasons only

CREATE VIEW [dbo].[UN_RU_Corrector]
AS

SELECT 
 [DimSourceID],
 N'UN2018-EXTENDED' as DefinitionName, 
 [GeoStandardName],
 [DimIndicatorID],
 [Year],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='UN2018' AND 
 ([FactQuery].IndicatorStandardCode='GDP-TOTAL-USD-CURRENT' OR
  [FactQuery].IndicatorStandardCode='POPULATION')
UNION
SELECT 
 [DimSourceID],
 N'UN2018-EXTENDED' as DefinitionName, 
 [GeoStandardName],
 [DimIndicatorID],
 [Year],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].SourceName='PENN' AND 
 (Year>=1970) AND
 (GeoStandardName='Taiwan') AND
 ([FactQuery].IndicatorStandardCode='GDP-TOTAL-USD-CURRENT' OR
  [FactQuery].IndicatorStandardCode='POPULATION')
GO

-- plonk the UN definitions into a temporary file so we can edit out the duplicates
 
BEGIN TRY 
DROP TABLE [dbo].[UN_TD_File] 
END TRY 
BEGIN CATCH
END CATCH
GO

SELECT 
 [DimSourceID],
 [DefinitionName], 
 [GeoStandardName],
 [DimIndicatorID],
 [Year],
 [YearAsDate],
 [Value]
INTO dbo.UN_TD_File
 FROM [UN_RU_Corrector]
GO
 
 
-- delete duplicated entries 

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1990) 
AND ([GeoStandardName]='USSR')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1990) 
AND ([GeoStandardName]='Yugoslavia')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1990) 
AND ([GeoStandardName]='Ethiopia (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1991) 
AND ([GeoStandardName]='Ethiopia (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1992) 
AND ([GeoStandardName]='Ethiopia (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1993) 
AND ([GeoStandardName]='Ethiopia (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 1990) 
AND ([GeoStandardName]='Czechoslovakia (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 2008) 
AND ([GeoStandardName]='Sudan (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 2009) 
AND ([GeoStandardName]='Sudan (Former)')

DELETE FROM [dbo].[UN_TD_File] 
WHERE ([UN_TD_File].[Year]= 2010) 
AND ([GeoStandardName]='Sudan (Former)')

-- TODO: former Indonesia?
-- TODO: former Netherlands Antilles

BEGIN TRY
DROP VIEW [dbo].[UN_RU_Corrector_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[UN_RU_Corrector_KeyFinder]
AS
SELECT
 UN_TD_File.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeo.DimGeoID,
 UN_TD_File.DimIndicatorID,
 UN_TD_File.YearAsDate,
 UN_TD_File.Value
FROM [UN_TD_File] INNER JOIN DimGeo ON
 DimGeo.GeoStandardName=UN_TD_File.GeoStandardName
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=UN_TD_File.DefinitionName
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
FROM UN_RU_Corrector_KeyFinder
GO 

-- MADDISON

-- Create the MADDISON Corrector view
BEGIN TRY
DROP VIEW [dbo].[MADDISON_RU_Corrector]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[MADDISON_RU_Corrector]
AS
-- Select all MADDISON Records
SELECT 
 [DimSourceID],
 N'MADDISON-EXTENDED' as DefinitionName, 
 [GeoStandardName],
 [ReportingUnit],
 [DimIndicatorID],
 [Year],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='MADDISON' 
GO

-- plonk the MADDISON definitions into a temporary file so we can edit out the duplicates
 
BEGIN TRY 
DROP TABLE [dbo].[MADDISON_TD_File] 
END TRY 
BEGIN CATCH
END CATCH
GO

SELECT 
 [DimSourceID],
 [DefinitionName], 
 [GeoStandardName],
 [ReportingUnit],
 [DimIndicatorID],
 [Year],
 [YearAsDate],
 [Value]
INTO dbo.MADDISON_TD_File
 FROM [MADDISON_RU_Corrector]
GO
 
-- delete duplicated entries 

DELETE FROM [dbo].[MADDISON_TD_File] 
WHERE 
([MADDISON_TD_File].[GeoStandardName]= 'Czech Republic') OR 
([MADDISON_TD_File].[GeoStandardName]= 'Slovak Republic')

-- delete duplicated USSR components

DELETE FROM [dbo].[MADDISON_TD_File] 
WHERE 
([MADDISON_TD_File].[ReportingUnit]= 'USSR') AND
([MADDISON_TD_File].[GeoStandardName] <> 'USSR')


BEGIN TRY
DROP VIEW [dbo].[MADDISON_RU_Corrector_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[MADDISON_RU_Corrector_KeyFinder]
AS
SELECT
 MADDISON_TD_File.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeo.DimGeoID,
 MADDISON_TD_File.DimIndicatorID,
 MADDISON_TD_File.YearAsDate,
 MADDISON_TD_File.Value
FROM [MADDISON_TD_File] INNER JOIN DimGeo ON
 DimGeo.GeoStandardName=MADDISON_TD_File.GeoStandardName
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=MADDISON_TD_File.DefinitionName
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
FROM MADDISON_RU_Corrector_KeyFinder
GO 


-- WID

-- Create the WID Corrector view
BEGIN TRY
DROP VIEW [dbo].[WID_RU_Corrector]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[WID_RU_Corrector]
AS
-- Select all WID Records
SELECT 
 [DimSourceID],
 N'WID-EXTENDED' as DefinitionName, 
 [GeoStandardName],
 [ReportingUnit],
 [DimIndicatorID],
 IndicatorStandardCode,
 [Year],
 [YearAsDate],
 [Value]
FROM [FactQuery]
 WHERE [FactQuery].DefinitionName='WID'
  AND IndicatorStandardCode='GDP-NET-TOTAL-LCU-CURRENT'
  or IndicatorStandardCode='GDP-FOREIGN-INCOME-LCU'
GO

-- plonk the WID definitions into a temporary file so we can edit out the duplicates
 
BEGIN TRY 
DROP TABLE [dbo].[WID_TD_File] 
END TRY 
BEGIN CATCH
END CATCH
GO

SELECT 
 [DimSourceID],
 [DefinitionName], 
 [GeoStandardName],
 [ReportingUnit],
 [IndicatorStandardCode],
 [Year],
 [YearAsDate],
 [Value]
INTO dbo.WID_TD_File
 FROM [WID_RU_Corrector]
GO
 
-- delete duplicated entries for Czechoslovakia

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[GeoStandardName]= 'Czechoslovakia (Former)')  AND
Year=1990

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[GeoStandardName]= 'Czech Republic')  AND
Year=1992

-- delete duplicated USSR components

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[ReportingUnit]= 'USSR') AND
(IndicatorStandardCode='GDP-NET-TOTAL-LCU-CURRENT')AND
(Year<1990)

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[ReportingUnit]= 'USSR') AND
(IndicatorStandardCode='GDP-FOREIGN-INCOME-LCU')AND
(Year<2002)

-- delete duplicated Yugoslavia components

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[ReportingUnit]= 'Yugoslavia') AND
(IndicatorStandardCode='GDP-FOREIGN-INCOME-LCU')AND
(Year<2007)

-- Ethiopia 

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[GeoStandardName]= 'Eritrea')

-- Indonesia

DELETE FROM [dbo].[WID_TD_File] 
WHERE 
([WID_TD_File].[GeoStandardName]= 'Timor-Leste')


BEGIN TRY
DROP VIEW [dbo].[WID_RU_Corrector_KeyFinder]
END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[WID_RU_Corrector_KeyFinder]
AS
SELECT
 WID_TD_File.DimSourceID,
 DimDefinitions.DimDefinitionID,
 DimGeo.DimGeoID,
 DimIndicator.DimIndicatorID,
 WID_TD_File.YearAsDate,
 WID_TD_File.Value
FROM [WID_TD_File] INNER JOIN DimGeo ON
 DimGeo.GeoStandardName=WID_TD_File.GeoStandardName
INNER JOIN DimDefinitions ON
 DimDefinitions.DefinitionName=WID_TD_File.DefinitionName
INNER JOIN DimIndicator ON
 DimIndicator.IndicatorStandardCode=WID_TD_File.IndicatorStandardCode 
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
FROM WID_RU_Corrector_KeyFinder
GO 



