-- The OLTP database is where the source data and dimension templates are initially loaded.
-- After they have been standardised and where necessary unpivoted, the results are copied
-- to the ROLAP database, which provides a clean version that is fully relational.
-- The ROLAP database is the source for all client data whether online or offline
 
USE [MACROHISTORY_OLTP]
GO

/* Different suppliers of data (UN, WDI, IFS, etc) use varying names for countries.
 * The geoStandardNames table allows us to replace these varying names by a single standardised name.
 * This table is used only on the OLTP server and is not copied to the ROLAP server.
 * Hence the ROLAP server deals only with the standard geo names
 */


-- GeoStandardNames transforms the different country names that are used by the various sources into a standardised name
-- NOTE: if two sources use the same name for different countries, the simple view we use at present won't catch that.
-- However the sources is recorded in this table so if the need arises, the deficiency can be corrected


-- this table is used on the OLTP server to standardise geographic names.
-- works in conjunction with DimGeo, in that it reduces each geographic names to a unique 'GeoStandardName'
-- which identifies a unique DimGeo record

DROP TABLE IF EXISTS GeoStandardNames

CREATE TABLE GeoStandardNames (
		-- The source of the data (eg UN2018,WDI2012,PALGRAVE, ETC). Not used (at 19/08/2018) at present; here for information
	 GeoSource nvarchar (255) NULL, 
		-- 	What the country or region is called by the source. Varies from source to source, which is why we have to standardise.
	 GeoSourceName nvarchar (255) NOT NULL, 
		-- A standard name by which the country or region is known on the ROLAP and Analysis servers 
		-- currently (9/12/2018) this is also the name by which the country is known to the user, but this
		-- could be changed by supplying a different name via DimGeo	
	 GeoStandardName nvarchar (255) NULL 

 CONSTRAINT PK_StandardGeO PRIMARY KEY CLUSTERED 
(
	 GeoSourceName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) )
GO


-- The DimGeo table is created on the OLTP server so that we can generate a GeoID that can be written into the fact file.
-- The DimGeo table is copied to the ROLAP server at ROLAP setup time.
-- In this way, the fact file need only contain the DimGeoID and can link to the DimGeo table which contains all the Dimension information


DROP TABLE IF EXISTS DimGeo
GO

CREATE TABLE DimGeo (
 DimGeoID int NOT NULL IDENTITY(1,1),
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

GO

-- this table is used on the OLTP server to standardise indicator names.
-- unlike GeoStandardNames, it does not directly result in a user-friendly name.
-- instead, it produces a standard name, by which the indicator is known in DimIndicator.
-- DimIndicator provides the user-friendly naming system.

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
	 IndicatorSource , IndicatorSourceCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) )
GO


-- The indicator Dimension table 
DROP TABLE IF EXISTS DimIndicator

-- IndicatorStandardName	Indicator Type	Component	Approach	Net or Gross	Paid or Received	Description	Industrial Sector	Measure Type	Dimensions	Metrics	Units

CREATE TABLE DimIndicator (
	DimIndicatorID int NOT NULL IDENTITY (1,1), 
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

-- The Source Dimension lists the various sources 
DROP TABLE IF EXISTS DimSource
GO

CREATE TABLE DimSource (
 DimSourceID int NOT NULL IDENTITY (1,1),
 SourceName nvarchar (255),
 SourceNameParent nvarchar (255),
 SourceNameDetail nvarchar (255),
 Description nvarchar (255),
 DataOriginFile nvarchar (255),
 DataOriginURL nvarchar (255),
 PreparationNotes nvarchar (255),
 SourceNotes nvarchar (255),
 DataNotes nvarchar (255)
CONSTRAINT PK_Source PRIMARY KEY CLUSTERED 
(
	 DimSourceID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
)
GO

