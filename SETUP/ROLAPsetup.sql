-- Sets up the Relational Tables from which the Cube is built, on the ROLAP server which hosts the cube
-- These tables will be populated from the OLAP server
-- so any changes to the structure of the OLAP tables should be reflected in changes to these tables


USE [ROLAP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- The normalised fact file.
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

BEGIN TRY 
DROP TABLE [dbo].[Fact] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[Fact](

	[FactID] bigint NOT NULL IDENTITY (1,1),
	[DimSourceID] int NULL,
	[DimDefinitionID]int NULL,
	[DimGeoID] [int] NULL,
	[DimIndicatorID] [int] NULL,
	[YearAsDate] Date Null,
	[Value] [float] NULL
	CONSTRAINT [PK_FactID] PRIMARY KEY CLUSTERED 
(
	[FactID] ASC
)
	) 
	ON [PRIMARY]
GO

BEGIN TRY 
DROP INDEX [dbo].[ix_FactSource] 
END TRY 
BEGIN CATCH
END CATCH 


CREATE NONCLUSTERED INDEX [ix_Fact] ON [dbo].[Fact]
(
	[DimSourceID] ASC,
	[DimDefinitionID] ASC,
	[DimGeoID] ASC,
	[DimIndicatorID] ASC,
	[YearAsDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- Maps the indicator description in the source onto standard indicator and quantifier names
-- Note this simply replicates the definition in the OLTP database but without an auto-increment key, because that's generated when the OLTP table is created


BEGIN TRY 
DROP TABLE [dbo].[DimIndicator] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimIndicator](
	[DimIndicatorID] [int] NOT NULL,
	[IndicatorStandardCode][nvarchar] (256) NOT NULL,
	[Type][nvarchar](255)NULL,
	[IndicatorName] [nvarchar](255) NULL, 
	[Unit][nvarchar](255)NULL,
	[Measure] [nvarchar](255) NULL,
	[Qualifier] [nvarchar] (255) NULL,
CONSTRAINT [IX_IndicatorStandardCode] UNIQUE(IndicatorStandardCode),
CONSTRAINT [PK_DimIndicator] PRIMARY KEY CLUSTERED 
(
	[DimIndicatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO

-- NOTE: in the ROLAP version we do not have an auto-incrementing key because it's generated in the OLTP file
-- As with DimIndicator, simply replicates what is in the OLTP table but without an auto-increment key, because that's generated when the OLTP table is created

BEGIN TRY 
DROP TABLE [dbo].[DimGeo] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimGeo](
[DimGeoID] [int] NOT NULL,
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

BEGIN TRY 
DROP TABLE [dbo].[DimDate] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimDate](
	[Date] [datetime] NOT NULL,
	[Year] [int] NOT NULL
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


-- The Definitions Dimension lists the composite definitions which splice data from various sources

BEGIN TRY 
DROP TABLE [dbo].[DimDefinitions] 
END TRY 
BEGIN CATCH
END CATCH
GO

-- The Definitions Dimension lists the various sources as well as composite definitions which splice data from various sources

BEGIN TRY 
DROP TABLE [dbo].[DimDefinitions] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimDefinitions](
[DimDefinitionID] int NOT NULL,
[DefinitionName] [nvarchar](100),
[LongDescription]	[nvarchar] (255)
CONSTRAINT [PK_Definition] PRIMARY KEY CLUSTERED 
(
	[DimDefinitionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO

-- The Source Dimension lists the various sources 

BEGIN TRY 
DROP TABLE [dbo].[DimSource] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimSource](
[DimSourceID] int NOT NULL,
[SourceName] [nvarchar](50),
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

-- provides a tabular view of the data.
-- Not currently used except for internal test purposes, to scrutinise the database contents.
-- But is externally accessible so could be used for a tabular BI model

BEGIN TRY 
DROP VIEW [dbo].[FactQuery] 
END TRY 
BEGIN CATCH
END CATCH
GO

CREATE VIEW [dbo].[FactQuery]
AS
SELECT
 dbo.Fact.FactID,
 dbo.Fact.DimSourceID,
 dbo.DimSource.SourceName, 
 dbo.Fact.DimDefinitionID,
 dbo.DimDefinitions.DefinitionName, 
 dbo.Fact.DimGeoID,
 dbo.Fact.DimIndicatorID,
 dbo.DimGeo.GeoStandardName, 
 dbo.DimGeo.ReportingUnit,
 dbo.DimIndicator.IndicatorStandardCode,
 dbo.DimSource.SourceDescription,
 dbo.DimIndicator.Type,
 dbo.DimIndicator.IndicatorName,
 dbo.Fact.Value,
 dbo.Fact.YearAsDate,
 Year(Fact.YearAsDate) as Year
FROM dbo.Fact LEFT OUTER JOIN
 dbo.DimGeo ON dbo.Fact.DimGeoID = dbo.DimGeo.DimGeoID LEFT OUTER JOIN
 dbo.DimIndicator ON dbo.Fact.DimIndicatorID = dbo.DimIndicator.DimIndicatorID LEFT OUTER JOIN
 dbo.DimSource ON dbo.Fact.DimSourceID = dbo.DimSource.DimSourceID LEFT OUTER JOIN
 dbo.DimDefinitions ON dbo.Fact.DimDefinitionID=dbo.DimDefinitions.DimDefinitionID 
GO

