-- Sets up the Relational Tables from which the Cube is built, on the ROLAP server which hosts the cube
-- These tables will be populated from the OLAP server
-- so any changes to the structure of the OLAP tables should be reflected in changes to these tables


USE macrohistory_rolap
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

-- A normalised fact file for GDP definitions.
-- Introduced 14 October 2020 to start experimentally splitting the fact files into more meaningful chunks
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS GDP_definitions 
GO

CREATE TABLE GDP_definitions (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_GDP_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
)
	) 
GO

-- A normalised fact file for Balance of Payments.
-- Introduced 16 October 2020 to start experimentally splitting the fact files into more meaningful chunks
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS balance_of_payments
GO

CREATE TABLE balance_of_payments (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_BoP_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
)
	) 
GO

-- A normalised fact file for GDP expenditure components.
-- Introduced 16 October 2020 to start experimentally splitting the fact files into more meaningful chunks
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS GDP_components_of_expenditure
GO

CREATE TABLE GDP_components_of_expenditure (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_Components_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
)
	) 
GO

-- A normalised fact file for GDP sources (factor incomes).
-- Introduced 16 October 2020 to start experimentally splitting the fact files into more meaningful chunks
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS GDP_sources
GO

CREATE TABLE GDP_sources (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_sources_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
)
	) 
GO

-- A normalised fact file for Capital.
-- Introduced 16 October 2020 to start experimentally splitting the fact files into more meaningful chunks
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS Capital_Stock
GO

CREATE TABLE Capital_Stock (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_capital_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
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
 GeoStandardName  nvarchar(255) NULL,
 GeoPolitical_Type  nvarchar(255)NULL,	
 ReportingUnit nvarchar(255) NULL,	
 Size nvarchar(255) NULL,
 GeoEconomic_Region nvarchar(255) NULL,
 Geopolitical_Region nvarchar(255) NULL,
 wdi_availability nvarchar(255) NULL,
 Major_Blocs nvarchar(255) NULL,
 penn_availability nvarchar(255) NULL,
 MACROHISTORY_Geography nvarchar(255) NULL,
 WID_Geography nvarchar(255) NULL,
 IMF_main_category nvarchar(255) NULL,
 IMF_sub_category nvarchar(255) NULL,	
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
