-- The OLTP database is where the  source data and dimension templates are initially loaded.
-- After they have been standardised and where necessary unpivoted, the results are copied
-- to the ROLAP database, which provides a clean version that is fully relational.
-- The ROLAP database is the source for all client data whether online or offline
 
USE [OLTP]
GO

/* Different suppliers of data (UN, WDI, IFS, etc) use varying names for countries.
 * The geoStandardNames table allows us to replace these varying names by a single standardised name.
 * This table is used only on the OLTP server and is not copied to the ROLAP server.
 * Hence the ROLAP server deals only with the standard geo names
 */

 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- the Date Dimension allows us to group data by decade and other categories such as business cycle
BEGIN TRY 
DROP TABLE [dbo].[DimDate] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimDate](
	[Date] [date] NOT NULL,
	[year] [int] NOT NULL,
CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




-- GeoStandardNames transforms the different country names that are used by the various sources into a standardised name
-- NOTE: if two sources use the same name for different countries, the simple view we use at present won't catch that.
-- However the sources is recorded in this table so if the need arises, the deficiency can be corrected


-- this table is used on the OLTP server to standardise geographic names.
-- works in conjunction with DimGeo, in that it reduces each geographic names to a unique 'GeoStandardName'
-- which identifies a unique DimGeo record
BEGIN TRY 
DROP TABLE [dbo].[GeoStandardNames] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[GeoStandardNames](
		-- The source of the data (eg UN2018,WDI2012,PALGRAVE, ETC). Not used (at 19/08/2018) at present; here for information
	[GeoSource] [nvarchar](255) NULL, 
		-- 	What the country or region is called by the source. Varies from source to source, which is why we have to standardise.
	[GeoSourceName] [nvarchar](255) NOT NULL, 
		-- A standard name by which the country or region is known on the ROLAP and Analysis servers 
		-- currently (9/12/2018) this is also the name by which the country is known to the user, but this
		-- could be changed by supplying a different name via DimGeo	
	[GeoStandardName] [nvarchar](255) NULL 

 CONSTRAINT [PK_StandardGeO] PRIMARY KEY CLUSTERED 
(
	[GeoSourceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO


-- The DimGeo table is created on the OLTP server so that we can generate a GeoID that can be written into the fact file.
-- The DimGeo table is copied to the ROLAP server at ROLAP setup time.
-- In this way, the fact file need only contain the DimGeoID and can link to the DimGeo table which contains all the Dimension information

BEGIN TRY 
DROP TABLE [dbo].[DimGeo] 
END TRY 
BEGIN CATCH
END CATCH
GO


CREATE TABLE [dbo].[DimGeo](
[DimGeoID] [int] NOT NULL IDENTITY(1,1),
[GeoStandardName] [nvarchar](255) NULL,
[GeoPolitical Type] [nvarchar](255) NULL,	
[ReportingUnit] [nvarchar](255) NULL,	
[Size] [nvarchar](255) NULL,
[GeoEconomic Region] [nvarchar](255) NULL,
[Geopolitical Region] [nvarchar](255) NULL,
[Geopolitical Detail][nvarchar](255) NULL,
[Major Blocs] [nvarchar](255) NULL,
[Penn Geography] [nvarchar](255) NULL,
[MACROHISTORY Geography] [nvarchar](255) NULL,
[WID Geography] [nvarchar](255) NULL,
[IMF main category] [nvarchar](255) NULL,
[IMF sub-category] [nvarchar](255) NULL,	
 CONSTRAINT [PK_DimGeO] PRIMARY KEY CLUSTERED 
(
	[DimGeoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- this table is used on the OLTP server to standardise indicator codes.
-- unlike GeoStandardNames, it does not directly result in a user-friendly name.
-- instead, it produces a standard code, by which the indicator is known in DimIndicator.
-- DimIndicator provides the user-friendly naming system.

BEGIN TRY 
DROP TABLE [dbo].[IndicatorStandardCodes] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[IndicatorStandardCodes](
		-- the source of the data (eg UN2018). Unlike GeoStandardNames, this field is needed 
		-- because two sources may use the same name for two different indicators
	[IndicatorSource] [nvarchar] (50) NOT NULL, 
	[IndicatorSourceDescription] [nvarchar](255) NOT NULL,
		-- many sources also have an ID system of their own. For completeness, this is recorded here, but not (9/12/2018) currently used.
	[IndicatorSourceCode] [nvarchar](255) NOT NULL,
		-- a standard code which identifies the indicator uniquely on the ROLAP server
	[IndicatorStandardCode] [nvarchar](255) NOT NULL
 CONSTRAINT [PK_IndicatorSourceName] PRIMARY KEY CLUSTERED 
(
	[IndicatorSource],[IndicatorSourceCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO


-- The indicator Dimension table 
BEGIN TRY 
DROP TABLE [dbo].[DimIndicator] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimIndicator](
	[DimIndicatorID] [int] NOT NULL IDENTITY (1,1), 
		-- the standard code which identifies this indicator uniquely on the ROLAP server (and hence in the cube)
	[IndicatorStandardCode][nvarchar] (256) NOT NULL,
	[Type][nvarchar](255)NULL,
	[IndicatorName] [nvarchar](255) NULL, 
	[Sector] [nvarchar](255) NULL,
	[Qualifier] [nvarchar] (255) NULL, 
	[Unit][nvarchar](255)NULL,
	[Measure] [nvarchar](255) NULL,
	[BaseYear] [nvarchar](255) NULL
 CONSTRAINT [IX_IndicatorStandardCode] UNIQUE(IndicatorStandardCode),	
 CONSTRAINT [PK_DimIndicator] PRIMARY KEY CLUSTERED 
(
	[DimIndicatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO

-- The Source Dimension lists the various sources 
BEGIN TRY 
DROP TABLE [dbo].[DimSource] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimSource](
[DimSourceID] int NOT NULL IDENTITY (1,1),
[SourceName] [nvarchar](255),
[SourceDetail] [nvarchar](255),
[SourceDescription] [nvarchar] (255),
[SourceFile] [nvarchar] (255),
[SourceURL] [nvarchar] (255),
[Preparation Notes] [nvarchar](255),
[Source Notes] [nvarchar] (255),
[Data Notes] [nvarchar] (255)
CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[DimSourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO

-- The Definitions Dimension lists the various sources as well as composite definitions which splice data from various sources
BEGIN TRY 
DROP TABLE [dbo].[DimDefinitions] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimDefinitions](
[DimDefinitionID] int NOT NULL IDENTITY (1,1),
[DefinitionName] [nvarchar](100),
[LongDescription]	[nvarchar] (255)
CONSTRAINT [PK_Definition] PRIMARY KEY CLUSTERED 
(
	[DimDefinitionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO



