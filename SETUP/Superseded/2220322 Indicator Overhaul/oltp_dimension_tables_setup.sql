-- The OLTP database is where the source data and dimension templates are initially loaded.
-- After they have been standardised and where necessary unpivoted, the results are copied
-- to the ROLAP database, which provides a clean version that is fully relational.
-- The ROLAP database is the source for all client data whether online or offline
 
USE [MACROHISTORY_OLTP]
GO


-- New standardised indicator table introduced March 2022. Combines information from what were previously
-- the two separate tables DimIndicator and IndicatorStandardNames

Drop table if exists IndicatorStandardisedDimensionTable
CREATE TABLE [dbo].[IndicatorStandardisedDimensionTable](
	[IndicatorStandardisedID] [int] NOT NULL IDENTITY (1,1),
	[IndicatorSource] [nvarchar](255) NOT NULL,
	[IndicatorSourceDescription] [nvarchar](255) NULL,
	[IndicatorStandardName] [nvarchar](256) NOT NULL,
	[indicator_type] [nvarchar](255) NULL,
	[component] [nvarchar](255) NULL,
	[accounting_basis] [nvarchar](255) NULL,
	[industrial_sector] [nvarchar](255) NULL,
	[measure_type] [nvarchar](255) NULL,
	[supplementary] [nvarchar](255) NULL,
	[output_definition] [nvarchar](255) NULL,
	[indicator_dimension] [nvarchar](255) NULL,
	[indicator_metrics] [nvarchar](255) NULL,
	[IndicatorSourceCode] [nvarchar](255) NOT NULL,
) ON [PRIMARY]
GO

-- New standardised geography table introduced March 2022. Combines information from what were previously
-- the two separate tables DimGeo and GeoStandardNames

DROP TABLE IF EXISTS [GeoStandardisedDimensionTable]

CREATE TABLE [dbo].[GeoStandardisedDimensionTable](
	[GeoStandardisedID] [int] IDENTITY(1,1) NOT NULL,
	[GeoPolitical_Type] [nvarchar](255) NULL,
	[GeoStandardName] [nvarchar](255) NULL,
	[ReportingUnit] [nvarchar](255) NULL,
	[GeoEconomic_Region] [nvarchar](255) NULL,
	[Major_Blocs] [nvarchar](255) NULL,
	[NICS_geography] [nvarchar](255) NULL,
	[Geopolitical_region] [nvarchar](255) NULL,
	[Maddison_availability] [nvarchar](255) NULL,
	[wdi_availability] [nvarchar](255) NULL,
	[penn_availability] [nvarchar](255) NULL,
	[MACROHISTORY_Geography] [nvarchar](255) NULL,
	[WID_Geography] [nvarchar](255) NULL,
	[IMF_main_category] [nvarchar](255) NULL,
	[WEO_Geography] [nvarchar](255) NULL,
	[Size] [nvarchar](255) NULL,
	[GeoSourceName] [nvarchar](255) NOT NULL
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