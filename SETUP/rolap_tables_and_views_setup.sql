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

DROP TABLE IF EXISTS fact_GDP_definitions 
GO

CREATE TABLE fact_GDP_definitions (
	 Fact_GDP_ID bigint NOT NULL IDENTITY (1,1),
	 DimSourceID int NULL,
	 DimGeoID int NULL,
	 DimIndicatorID int NULL,
	 DateField Date Null,
	 Value float NULL
	CONSTRAINT PK_Fact_GDP_ID PRIMARY KEY CLUSTERED 
(
	 Fact_GDP_ID ASC
)
	) 
GO

-- Maps the indicator description in the source onto standard indicator and quantifier names
-- Note this simply replicates the definition in the OLTP database but without an auto-increment key, because that's generated when the OLTP table is created

DROP TABLE IF EXISTS DimIndicator 
GO

CREATE TABLE DimIndicator (
	 DimIndicatorID int NOT NULL, 
		-- the standard name which identifies this indicator uniquely on the ROLAP server (and hence in the cube)
	 IndicatorStandardName nvarchar (256) NOT NULL,
	 indicator_type nvarchar(255) NULL,
	gdp_Expenditure_Component	nvarchar (255)NULL,
	capital_component nvarchar (255)NULL,
	source_component nvarchar (255)NULL,
	balance_of_payments_component nvarchar (255)NULL,
	population_component nvarchar (255)NULL,
	other nvarchar (255)NULL,
	gdp_approach_variation nvarchar (255)NULL,
	description nvarchar (255)NULL,
	industrial_sector nvarchar (255)NULL,
	net_or_gross nvarchar (255)NULL,
	paid_or_received nvarchar (255)NULL,
	measure_type nvarchar (255)NULL,
	dimensions nvarchar (255)NULL,
	units nvarchar (255)NULL,
	metrics nvarchar (255)NULL
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
 Geopolitical_Detail nvarchar(255) NULL,
 Major_Blocs nvarchar(255) NULL,
 Penn_Geography nvarchar(255) NULL,
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
  DimIndicator.other ,
  DimIndicator.gdp_approach_variation ,
  DimIndicator.description as indicator_description,
  DimIndicator.industrial_sector ,
  DimIndicator.net_or_gross ,
  DimIndicator.paid_or_received ,
  DimIndicator.measure_type ,
  DimIndicator.dimensions ,
  DimIndicator.units ,
  DimIndicator.metrics ,
 Fact.Value,
 Fact.DateField
FROM Fact LEFT OUTER JOIN
 DimGeo ON Fact.DimGeoID = DimGeo.DimGeoID LEFT OUTER JOIN
 DimIndicator ON Fact.DimIndicatorID = DimIndicator.DimIndicatorID LEFT OUTER JOIN
 DimSource ON Fact.DimSourceID = DimSource.DimSourceID
GO



