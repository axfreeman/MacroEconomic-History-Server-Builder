-- The OLTP database is where the source data and dimension templates are initially loaded (see Dimension Setup for details)
 
USE macrohistory_oltp
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

-- The FactSource file amalgamates data from all the various sources in a standard form.
-- Alphanumeric names are used for the Geo, Indicator and Quantifier fields.
-- it is then optimised by the 'FactStandardQuery' view, which substitutes integer primary keys 
-- for these alphanumeric fields. 
-- When the ROLAP server is initialised, the FactStandardQuery is coped to the ROLAP server.
-- The size of the fields is restricted to avoid overrunning the space restrictions of an SQLEXPRESS server
-- for installations with no size restrictions, they can be raised if need arises

DROP TABLE IF EXISTS FactSource
GO
CREATE TABLE [FactSource](
 [OLTP_FactID] bigint not null IDENTITY (1,1), /* this key isn't used but helps track and debug problem rows */
 [SourceName] [nvarchar](50) NULL, /* the source is a single provider at a single release date, eg UN2018, WB2015*/
 [DefinitionName] nvarchar(50)NULL, /* the 'definition' is a selection of records from different providers. Initially, the selection for a given source will simply be the source */
 [GeoSourceName] [nvarchar](255) NULL, /* the geographical unit as defined by the supplier. This is standardised using geoStandardNames because every source has a different name for the same country */
 [IndicatorSourceCode] [nvarchar](255) NULL, 
 [Year] int NULL,
 [Value] float NULL
 	CONSTRAINT [PK_OLTP_FactID] PRIMARY KEY CLUSTERED 
(
	[OLTP_FactID] ASC
)
	
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ix_FactSource] ON [FactSource]
(
	[SourceName] ASC,
	[DefinitionName] ASC,
	[GeoSourceName] ASC,
	[IndicatorSourceCode] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-- selects, from the factSource file, those rows which contain countries and indicators that we know about (by including them in the DimGeo and DimIndicator tables)
-- INCLUDE countries for which there is no data so that, when a pivot table is created, the countries are laid out with the same spacing
-- for each indicator and source.
-- But EXCLUDE indicators for which there is no data, or there would be too much clutter.


CREATE OR ALTER VIEW [RecognisedFacts]
AS
SELECT
 dbo.FactSource.OLTP_FactID,
 dbo.FactSource.SourceName,
 dbo.FactSource.DefinitionName,
 dbo.DimSource.DimSourceID,
 dbo.DimDefinitions.DimDefinitionID,
 dbo.FactSource.GeoSourceName,
 dbo.GeoStandardNames.GeoStandardName,
 dbo.FactSource.IndicatorSourceCode as [Fact Indicator Name],
 dbo.IndicatorStandardNames.IndicatorSourceCode,
 dbo.IndicatorStandardNames.IndicatorStandardName, 
 dbo.FactSource.Year,
 dbo.FactSource.Value
FROM dbo.FactSource
 RIGHT OUTER JOIN dbo.GeoStandardNames
 ON dbo.FactSource.GeoSourceName = dbo.GeoStandardNames.GeoSourceName
 RIGHT OUTER JOIN dbo.IndicatorStandardNames
 ON dbo.FactSource.SourceName = dbo.IndicatorStandardNames.IndicatorSource 
 AND dbo.FactSource.IndicatorSourceCode = dbo.IndicatorStandardNames.IndicatorSourceCode
 INNER JOIN dbo.DimSource
 ON dbo.FactSource.SourceName=dbo.DimSource.SourceName
 INNER JOIN dbo.DimDefinitions
 ON dbo.FactSource.DefinitionName=dbo.dimDefinitions.DefinitionName
WHERE (dbo.FactSource.Year IS NOT NULL) AND (dbo.FactSource.Year > 1700) and (Value<>0)
GO

-- Compresses the rows of the RecognisedFacts view by substituting the integer Indexes of DimGeo and DimIndicator for the actual country and indicator names

CREATE OR ALTER VIEW [FactQuery]
AS
SELECT 
dbo.RecognisedFacts.OLTP_FactID,
dbo.RecognisedFacts.SourceName, 
dbo.RecognisedFacts.DefinitionName, 
dbo.RecognisedFacts.DimSourceID,
dbo.RecognisedFacts.DimDefinitionID,
dbo.RecognisedFacts.Year, 
dbo.RecognisedFacts.Value, 
dbo.DimIndicator.DimIndicatorID, 
dbo.DimGeo.DimGeoID, 
dbo.RecognisedFacts.GeoStandardName, 
dbo.RecognisedFacts.IndicatorStandardName, 
TRY_CONVERT(DateTime, STR(dbo.RecognisedFacts.Year) + '-01-01') AS YearAsDate
FROM dbo.RecognisedFacts LEFT OUTER JOIN
 dbo.DimIndicator ON 
 dbo.RecognisedFacts.IndicatorStandardName = dbo.DimIndicator.IndicatorStandardName LEFT OUTER JOIN
 dbo.DimGeo ON 
 dbo.RecognisedFacts.GeoStandardName = dbo.DimGeo.GeoStandardName
GO

