-- The OLTP database is where the source data and dimension templates are initially loaded.
-- After they have been standardised and where necessary unpivoted, the results are copied
-- to the ROLAP database, which provides a clean version that is fully relational.
-- The ROLAP database is the source for all client data whether online or offline
 
USE [MACROHISTORY_OLTP_230505]
GO

Drop table if exists IndicatorStandardisedDimensionTable
GO

CREATE TABLE [dbo].[IndicatorStandardisedDimensionTable](
	[StandardisedID] [int]  IDENTITY (1,1),
	[SourceName] [nvarchar](255) NOT NULL, /* was 'IndicatorSource' */
	[SourceCode] [nvarchar](255) NOT NULL, /* was 'IndicatorSourceCode' */
	[SourceDescription] [nvarchar](255) NOT NULL, 
	[StandardCode] [nvarchar](255) NOT NULL, /* was 'IndicatorStandardName, was 256 */
	[StandardDescription][nvarchar](255) NULL, /* new */
	[IndicatorType] [nvarchar](255) NULL, /* was 'indicator_type' */
	[IndicatorComponent][nvarchar](255) NULL, /* New */
	[Sector][nvarchar](255) NULL, /* was 'industrial_sector' */
	[AssetType][nvarchar](255) NULL, /* new */
	[accounting_basis] [nvarchar](255) NULL,
	[MeasureType] [nvarchar](255) NULL, /* was measure_type */
	[MeasureDimension] [nvarchar](255) NULL, /*was indicator_dimension */
	[MeasureMetric] [nvarchar](255) NULL, /* was indicator_measure */
	[MeasureUnits] [nvarchar](255) NULL, /* was indicator_units */
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [GeoStandardisedDimensionTable]
GO
CREATE TABLE [dbo].[GeoStandardisedDimensionTable](
	[GeoStandardisedID] [int] IDENTITY(1,1) NOT NULL,
	[GeoSourceName] [nvarchar](255) NOT NULL,
	[GeoPolitical_Type] [nvarchar](255) NULL,
	[GeoStandardName] [nvarchar](255) NULL,
	[ReportingUnit] [nvarchar](255) NULL,
	[GeoEconomic_Region] [nvarchar](255) NULL,
	[Major_Blocs] [nvarchar](255) NULL,
	[WEO_Geography] [nvarchar](255) NULL,
	[Available_From] [nvarchar](255) NULL,
	[Available_Until] [nvarchar](255) NULL,
	[Size] [nvarchar](255) NULL,
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [GeoStandardNames]
GO

CREATE TABLE [dbo].[GeoStandardNames](
		[GeoStandardisedID] [int] IDENTITY(1,1) NOT NULL,
	[GeoStandardName] [nvarchar](255) NOT NULL,
	[GeoSourceName] [nvarchar](255) NOT NULL,
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [DimGeo]
GO

CREATE TABLE [dbo].[DimGeo](
	[GeoStandardisedID] [int] IDENTITY(1,1) NOT NULL,
	[GeoStandardName] [nvarchar](255) NULL,
	[ReportingUnit] [nvarchar](255) NULL,
	[GeoPolitical_Type] [nvarchar](255) NULL,
	[GeoEconomic_Region] [nvarchar](255) NULL,
	[Major_Blocs] [nvarchar](255) NULL,
	[WEO_Geography] [nvarchar](255) NULL,
	[Available_From] [nvarchar](255) NULL,
	[Available_Until] [nvarchar](255) NULL,
	[Size] [nvarchar](255) NULL
) ON [PRIMARY]
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


CREATE OR ALTER VIEW [dbo].[GeoStandardisedDimensionView]
AS
SELECT        dbo.GeoStandardNames.GeoSourceName, dbo.DimGeo.GeoStandardisedID, dbo.DimGeo.GeoStandardName, 
GeoPolitical_Type,
dbo.DimGeo.ReportingUnit, 
dbo.DimGeo.GeoEconomic_Region, 
dbo.DimGeo.Major_Blocs, 
dbo.DimGeo.Available_From, 
Available_Until,                 
dbo.DimGeo.Size, 
dbo.DimGeo.WEO_Geography
FROM            dbo.DimGeo RIGHT OUTER JOIN
                         dbo.GeoStandardNames ON dbo.DimGeo.GeoStandardName = dbo.GeoStandardNames.GeoStandardName
GO




