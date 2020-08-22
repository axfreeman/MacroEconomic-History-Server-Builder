-- Sets up the Relational Tables from which the Cube is built, on the ROLAP server which hosts the cube
-- These tables will be populated from the OLAP server
-- so any changes to the structure of the OLAP tables should be reflected in changes to these tables


USE macrohistory_rolap
GO

-- The normalised fact file.
-- What the Cube sees is a selection of Fact records defined by their FactID
-- in which the details of each dimension (Geography, indicator, series breaks, date) are
-- provided by dimension files related to the relevant Foreign Key in the fact file.

DROP TABLE IF EXISTS [dbo].[Fact] 
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

DROP INDEX IF EXISTS [dbo].[ix_FactSource] 
GO

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


DROP TABLE IF EXISTS [dbo].[DimIndicator] 
GO

CREATE TABLE [dbo].[DimIndicator](
	[DimIndicatorID] [int] NOT NULL,
	[IndicatorStandardName][nvarchar] (256) NOT NULL,
	[Type][nvarchar](255)NULL,
	[Indicator] [nvarchar](255) NULL, 
	[Sector] [nvarchar](255) NULL,
	[Qualifier] [nvarchar] (255) NULL, 
	[Unit][nvarchar](255)NULL,
	[Measure] [nvarchar](255) NULL,
	[BaseYear] [nvarchar](255) NULL,
CONSTRAINT [IX_IndicatorStandardName] UNIQUE(IndicatorStandardName),
CONSTRAINT [PK_DimIndicator] PRIMARY KEY CLUSTERED 
(
	[DimIndicatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
GO

-- NOTE: in the ROLAP version we do not have an auto-incrementing key because it's generated in the OLTP file
-- As with DimIndicator, simply replicates what is in the OLTP table but without an auto-increment key, because that's generated when the OLTP table is created

DROP TABLE IF EXISTS [dbo].[DimGeo] 
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

DROP TABLE IF EXISTS [dbo].[DimDate] 
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

DROP TABLE IF EXISTS [dbo].[DimDefinitions] 
GO

-- The Definitions Dimension lists the various sources as well as composite definitions which splice data from various sources

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

DROP TABLE IF EXISTS [dbo].[DimSource] 
GO

CREATE TABLE [dbo].[DimSource](
[DimSourceID] int NOT NULL,
[SourceName] [nvarchar](255),
[SourceNameParent] [nvarchar](255),
[SourceNameDetail] [nvarchar](255),
[Description] [nvarchar] (255),
[DataOriginFile] [nvarchar] (255),
[DataOriginURL] [nvarchar] (255),
[PreparationNotes] [nvarchar](255),
[SourceNotes] [nvarchar] (255),
[DataNotes] [nvarchar] (255)
CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[DimSourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO

-- Provides a tabular view of the data for debugging purposes

CREATE OR ALTER VIEW [dbo].[FactQuery]
AS
SELECT
 dbo.Fact.FactID,
 dbo.Fact.DimSourceID,
 dbo.DimSource.SourceName, 
 dbo.DimSource.SourceNameParent, 
 dbo.DimSource.SourceNameDetail, 
 dbo.DimSource.Description,
 dbo.Fact.DimDefinitionID,
 dbo.DimDefinitions.DefinitionName, 
 dbo.Fact.DimGeoID,
 dbo.DimGeo.GeoStandardName, 
 dbo.DimGeo.ReportingUnit,
 dbo.Fact.DimIndicatorID,
 dbo.DimIndicator.IndicatorStandardName,
 dbo.DimIndicator.Type,
 dbo.DimIndicator.Indicator,
 dbo.DimIndicator.Sector,
 dbo.DimIndicator.Qualifier,
 dbo.DimIndicator.Unit,
 dbo.DimIndicator.Measure,
 dbo.DimIndicator.BaseYear,
 dbo.Fact.Value,
 dbo.Fact.YearAsDate,
 Year(Fact.YearAsDate) as Year
FROM dbo.Fact LEFT OUTER JOIN
 dbo.DimGeo ON dbo.Fact.DimGeoID = dbo.DimGeo.DimGeoID LEFT OUTER JOIN
 dbo.DimIndicator ON dbo.Fact.DimIndicatorID = dbo.DimIndicator.DimIndicatorID LEFT OUTER JOIN
 dbo.DimSource ON dbo.Fact.DimSourceID = dbo.DimSource.DimSourceID LEFT OUTER JOIN
 dbo.DimDefinitions ON dbo.Fact.DimDefinitionID=dbo.DimDefinitions.DimDefinitionID 
GO


CREATE OR ALTER VIEW [dbo].[FactQueryCapitalStock]
AS
SELECT FactID, DimSourceID, DimDefinitionID, DimGeoID, DimIndicatorID, YearAsDate, Value
FROM   dbo.FactQuery
WHERE  (Type = N'GDP Measures' OR
          Type = N'Capital' OR
          Type = N'GDP Components' OR
          Type = N'Demography and Labour' OR
          Type = N'Indices') AND (SourceName = 'UN2018' OR
          SourceName = 'MADDISON' OR
          SourceName = 'MACROHIST' OR
          SourceName = 'BARRO-URSUA' OR
		  SourceName='Eurostat' OR
          SourceName = 'PENN' OR
          SourceName = 'OECD')
GO


