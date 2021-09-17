-- Sets up the Relational Tables from which the Cube is built, on the ROLAP server which hosts the cube
-- These tables will be populated from the OLAP server
-- so any changes to the structure of the OLAP tables should be reflected in changes to these tables


USE [macrohistory_rolap_23.01.2021]
GO

-- The normalised fact file.
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS Fact 
GO

CREATE TABLE Fact (
 FactID bigint NOT NULL IDENTITY (1,1),
 DimSourceID int NULL,
 DimGeoID int NULL,
 DimIndicatorID int NULL,
 DateField Date Null,
 Value float NULL
 CONSTRAINT PK_FactID PRIMARY KEY CLUSTERED 
  (
   FactID ASC
  )
 ) 
GO


-- Indicator Standard Names is a mirror of the OLTP table of the same name
-- In the initialy OLTP stage, when data is being loaded from the raw sources, 
-- the OLTP table is used to convert the supplier's many different codes into a single standard code used by this project (the MacroEconomic History project)
-- here, in the ROLAP stage, it is used in the inverse sense, to retrieve the original description from the combination of the Source and the indicator code
-- we need to key on both the source and the indicator code, to get a unique key (since several suppliers will give data that corresponds to a single indicator).
-- That's why the primary key is different in this version of the table and in the OLTP version

DROP TABLE IF EXISTS IndicatorStandardNames
GO

CREATE TABLE IndicatorStandardNames (
		-- the source of the data (eg UN2018). Unlike GeoStandardNames, this field is needed 
		-- because two sources may use the same name for two different indicators
	 IndicatorSource nvarchar (255) NOT NULL, 
		-- many sources also have an ID system of their own. For completeness, this is recorded here, but not (9/12/2018) currently used.
	 IndicatorSourceDescription nvarchar (255) NULL,
		-- this is the code by which the source (provider) identifies the data. Sometimes it is a complex alphanumeric code, and sometimes it is just the description itself
	 IndicatorSourceCode nvarchar (255) NOT NULL,
		-- a standard name which identifies the indicator uniquely on the ROLAP server
	 IndicatorStandardName nvarchar (255) NOT NULL
 CONSTRAINT PK_IndicatorSourceKey PRIMARY KEY CLUSTERED 
(
	 IndicatorSource , IndicatorStandardName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) )
GO



-- Maps the indicator description in the source onto standard indicator and quantifier names
-- Note this simply replicates the definition in the OLTP database but without an auto-increment key, because that's generated when the OLTP table is created
-- indicator_type	gdp_expenditure_component	capital_component	source_component	balance_of_payments_component	population_component	indicator_other_information	gdp_approach_variation	indicator_description	industrial_sector	net_or_gross	paid_or_received	measure_type	indicator_dimension	indicator_units	indicator_metrics

DROP TABLE IF EXISTS DimIndicator 
GO

CREATE TABLE DimIndicator (
	DimIndicatorID int NOT NULL, 
	-- the standard name which identifies this indicator uniquely on the ROLAP server (and hence in the cube)
	IndicatorStandardName nvarchar (256) NOT NULL,
	indicator_type nvarchar (255)NULL,
	gdp_expenditure_component nvarchar (255)NULL,
	capital_component nvarchar (255)NULL,
	source_component nvarchar (255)NULL,
	balance_of_payments_component nvarchar (255)NULL,
	population_component nvarchar (255)NULL,
	other_indicator_description nvarchar (255)NULL,
	output_definition nvarchar (255)NULL,
	accounting_basis nvarchar (255) NULL,
	industrial_sector nvarchar (255)NULL,
	measure_type nvarchar (255)NULL,
	indicator_dimension nvarchar (255)NULL,
	indicator_units nvarchar (255)NULL,
	indicator_metrics nvarchar (255)NULL,
 CONSTRAINT IX_IndicatorStandardName UNIQUE(IndicatorStandardName),	
 CONSTRAINT PK_DimIndicator PRIMARY KEY CLUSTERED 
(
	 DimIndicatorID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) )
GO


-- NOTE: in the ROLAP version we do not have an auto-incrementing key because it's generated in the OLTP file
-- As with DimIndicator, simply replicates what is in the OLTP table but without an auto-increment key, because that's generated when the OLTP table is created

DROP TABLE IF EXISTS DimGeo 
GO


CREATE TABLE DimGeo (
 DimGeoID int NOT NULL,
 GeoStandardName nvarchar (255) NULL,
 GeoPolitical_Type nvarchar (255) NULL,	
 ReportingUnit nvarchar (255) NULL,	
 Size nvarchar (255) NULL,
 GeoEconomic_Region nvarchar (255) NULL,
 Major_Blocs nvarchar (255) NULL,
 NICS_geography nvarchar (255) NULL,
 Geopolitical_region nvarchar (255) NULL,
 Maddison_availability nvarchar (255) NULL,
 wdi_availability nvarchar (255) NULL,
 penn_availability nvarchar (255) NULL,
 MACROHISTORY_Geography nvarchar (255) NULL,
 WID_Geography nvarchar (255) NULL,
 IMF_main_category nvarchar (255) NULL,
 WEO_Geography nvarchar (255) NULL,	
 CONSTRAINT PK_DimGeO PRIMARY KEY CLUSTERED 
(
	 DimGeoID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
) 

-- The Source Dimension lists the various sources 

DROP TABLE IF EXISTS DimSource 
GO

CREATE TABLE DimSource (
 DimSourceID int NOT NULL,
 SourceName nvarchar(255) ,
 SourceNameParent nvarchar(255) ,
 SourceNameDetail nvarchar(255) ,
 Description nvarchar(255) ,
 DataOriginFile nvarchar(255) ,
 DataOriginURL nvarchar(255) ,
 PreparationNotes nvarchar(255) ,
 SourceNotes nvarchar(255) ,
 DataNotes nvarchar(255) 
CONSTRAINT PK_Source PRIMARY KEY CLUSTERED 
(
	 DimSourceID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
)
GO

-- Provides a tabular view of the data for debugging purposes
/* WAS
CREATE OR ALTER VIEW FactQuery 
AS
SELECT
 Fact.FactID,
 Fact.DimSourceID,
 DimSource.SourceName, 
 DimSource.SourceNameParent, 
 DimSource.SourceNameDetail, 
 DimSource.Description,
 Fact.DimGeoID,
 DimGeo.GeoStandardName, 
 DimGeo.ReportingUnit,
 Fact.DimIndicatorID,
 DimIndicator.IndicatorStandardName,
 DimIndicator.indicator_type ,
 DimIndicator.gdp_Expenditure_Component,
 DimIndicator.capital_component ,
 DimIndicator.source_component ,
 DimIndicator.balance_of_payments_component ,
 DimIndicator.population_component ,
 DimIndicator.other_indicator_description,
 DimIndicator.output_definition ,
 DimIndicator.industrial_sector ,
 DimIndicator.measure_type ,
 DimIndicator.indicator_dimension,
 DimIndicator.indicator_units,
 DimIndicator.indicator_metrics,
 Fact.Value,
 Fact.DateField
FROM Fact LEFT OUTER JOIN
 DimGeo ON Fact.DimGeoID = DimGeo.DimGeoID LEFT OUTER JOIN
 DimIndicator ON Fact.DimIndicatorID = DimIndicator.DimIndicatorID LEFT OUTER JOIN
 DimSource ON Fact.DimSourceID = DimSource.DimSourceID
GO
*/

CREATE OR ALTER VIEW FactQuery 
AS
SELECT dbo.Fact.FactID, dbo.Fact.DimSourceID, dbo.DimSource.SourceName, dbo.DimSource.SourceNameParent, dbo.DimSource.SourceNameDetail, dbo.DimSource.Description, dbo.Fact.DimGeoID, dbo.DimGeo.GeoStandardName, dbo.DimGeo.ReportingUnit, dbo.Fact.DimIndicatorID, dbo.DimIndicator.IndicatorStandardName, dbo.DimIndicator.indicator_type, 
         dbo.DimIndicator.gdp_expenditure_component, dbo.DimIndicator.capital_component, dbo.DimIndicator.source_component, dbo.DimIndicator.balance_of_payments_component, dbo.DimIndicator.population_component, dbo.DimIndicator.other_indicator_description, dbo.DimIndicator.output_definition, dbo.DimIndicator.industrial_sector, dbo.DimIndicator.measure_type, 
         dbo.DimIndicator.indicator_dimension, dbo.DimIndicator.indicator_units, dbo.DimIndicator.indicator_metrics, dbo.Fact.Value, dbo.Fact.DateField, dbo.DimIndicator.accounting_basis, dbo.DimGeo.GeoEconomic_Region, dbo.DimGeo.Major_Blocs, dbo.DimGeo.NICS_geography, dbo.DimGeo.Geopolitical_region, dbo.DimGeo.Maddison_availability, dbo.DimGeo.wdi_availability, 
         dbo.DimGeo.penn_availability, dbo.DimGeo.WID_Geography, dbo.DimGeo.IMF_main_category, dbo.DimGeo.WEO_Geography, dbo.DimGeo.MACROHISTORY_Geography, dbo.DimGeo.Size, dbo.DimGeo.GeoPolitical_Type
FROM  dbo.Fact LEFT OUTER JOIN
         dbo.DimGeo ON dbo.Fact.DimGeoID = dbo.DimGeo.DimGeoID LEFT OUTER JOIN
         dbo.DimIndicator ON dbo.Fact.DimIndicatorID = dbo.DimIndicator.DimIndicatorID LEFT OUTER JOIN
         dbo.DimSource ON dbo.Fact.DimSourceID = dbo.DimSource.DimSourceID

GO

-- this query contains a lagged variable so growth can easily be calculated
-- eventually, growth itself will replace this lagged variable

CREATE OR ALTER VIEW [dbo].[LaggedFactQuery]
AS

/*WAS
SELECT dbo.FactQuery.FactID, 
 dbo.FactQuery.DimSourceID, 
 dbo.FactQuery.DimGeoID,
 dbo.FactQuery.DimIndicatorID,
 dbo.FactQuery.DateField,
 dbo.FactQuery.Value,
 Fact_1.Value AS LaggedValue,
 dbo.FactQuery.SourceName,
 dbo.FactQuery.SourceNameParent,
 dbo.FactQuery.SourceNameDetail,
 dbo.FactQuery.Description,
 dbo.FactQuery.GeoStandardName, 
 dbo.FactQuery.ReportingUnit,
 dbo.FactQuery.indicator_type,
 dbo.FactQuery.gdp_Expenditure_Component,
 dbo.FactQuery.capital_component,
 dbo.FactQuery.source_component,
 dbo.FactQuery.balance_of_payments_component,
 dbo.FactQuery.population_component,
 dbo.FactQuery.other_indicator_description,
 dbo.FactQuery.output_definition,
 dbo.FactQuery.industrial_sector, 
 dbo.FactQuery.measure_type,
 dbo.FactQuery.indicator_dimension,
 dbo.FactQuery.indicator_units,
 dbo.FactQuery.indicator_metrics
FROM  dbo.FactQuery INNER JOIN
 dbo.Fact AS Fact_1 ON
 YEAR(dbo.FactQuery.DateField) = YEAR(Fact_1.DateField) - 1
 AND dbo.FactQuery.DimSourceID = Fact_1.DimSourceID
 AND dbo.FactQuery.DimGeoID = Fact_1.DimGeoID
 AND dbo.FactQuery.DimIndicatorID = Fact_1.DimIndicatorID
*/
SELECT dbo.FactQuery.FactID, dbo.FactQuery.DateField, dbo.FactQuery.Value, Fact_1.Value AS LaggedValue, dbo.FactQuery.SourceNameDetail, dbo.FactQuery.Description, dbo.FactQuery.GeoStandardName, dbo.FactQuery.ReportingUnit, dbo.FactQuery.indicator_type, dbo.FactQuery.gdp_Expenditure_Component, dbo.FactQuery.capital_component, dbo.FactQuery.source_component, 
         dbo.FactQuery.balance_of_payments_component, dbo.FactQuery.population_component, dbo.FactQuery.other_indicator_description, dbo.FactQuery.output_definition, dbo.FactQuery.industrial_sector, dbo.FactQuery.measure_type, dbo.FactQuery.indicator_dimension, dbo.FactQuery.indicator_units, dbo.FactQuery.indicator_metrics, dbo.FactQuery.IndicatorStandardName, 
         dbo.IndicatorStandardNames.IndicatorSourceDescription, dbo.FactQuery.SourceNameParent, dbo.FactQuery.gdp_expenditure_component AS Expr1, dbo.FactQuery.SourceName, dbo.FactQuery.accounting_basis, dbo.FactQuery.GeoEconomic_Region, dbo.FactQuery.Major_Blocs, dbo.FactQuery.NICS_geography, dbo.FactQuery.Geopolitical_region, 
         dbo.FactQuery.Maddison_availability, dbo.FactQuery.wdi_availability, dbo.FactQuery.penn_availability, dbo.FactQuery.WID_Geography, dbo.FactQuery.IMF_main_category, dbo.FactQuery.MACROHISTORY_Geography, dbo.FactQuery.WEO_Geography, dbo.FactQuery.Size, dbo.FactQuery.GeoPolitical_Type
FROM  dbo.FactQuery INNER JOIN
         dbo.Fact AS Fact_1 ON YEAR(dbo.FactQuery.DateField) = YEAR(Fact_1.DateField) - 1 AND dbo.FactQuery.DimSourceID = Fact_1.DimSourceID AND dbo.FactQuery.DimGeoID = Fact_1.DimGeoID AND dbo.FactQuery.DimIndicatorID = Fact_1.DimIndicatorID LEFT OUTER JOIN
         dbo.IndicatorStandardNames ON dbo.FactQuery.SourceName = dbo.IndicatorStandardNames.IndicatorSource AND dbo.FactQuery.IndicatorStandardName = dbo.IndicatorStandardNames.IndicatorStandardName

GO

-- Create a date table
-- at present only years, but we can add quarters, months  etc later

DROP TABLE IF EXISTS Calendar

CREATE TABLE Calendar( 
  [CalendarKey] [int] NULL, 
  [Date] [date] NULL, 
  [Year] [int] NULL, 

) ON [PRIMARY] 

declare @start_date date, @end_date date 
 
set @start_date = '01/01/1870' 
set @end_date = '01/01/2021' 
 
WHILE (@start_date<=@end_date) 
BEGIN 
 
INSERT INTO Calendar
SELECT 
[CalendarKey]=CONVERT(int,CONVERT(VARCHAR(15), @start_date, 112)), 
[Date]= @start_date, 
[Year] = DATEPART(YEAR,@start_date)

SET @start_date =DATEADD(year, 1, @start_date) 
 
END 
