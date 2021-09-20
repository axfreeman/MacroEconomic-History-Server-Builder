-- The OLTP database is where the source data and dimension templates are initially loaded (see Dimension Setup for details)
 
USE [MACROHISTORY_OLTP]
GO

/* Different suppliers of data (UN, WDI, IFS, etc) use varying names for countries.
 * The geoStandardNames table allows us to replace these varying names by a single standardised name.
 * This table is used only on the OLTP server and is not copied to the ROLAP server.
 * Hence the ROLAP server deals only with the standard geo names
 */

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
 [GeoSourceName] [nvarchar](255) NULL, /* the geographical unit as defined by the supplier. This is standardised using geoStandardNames because every source has a different name for the same country */
 [IndicatorSourceCode] [nvarchar](255) NULL, 
 [Date] DateTime NULL,
 [Value] float NULL
 	CONSTRAINT [PK_OLTP_FactID] PRIMARY KEY CLUSTERED 
(
	[OLTP_FactID] ASC
)
	
) ON [PRIMARY]
GO
-- the purpose of this index is to speed up those views which combine rows from the fact table with rows from dimension tables
-- it is commented out because the index takes up a lot of space, which prevents the project running on MSSQL Express
-- because that has a 10GB limit on the size of the database
/* CREATE NONCLUSTERED INDEX [ix_FactSource] ON [FactSource]
 (
	[SourceName] ASC,
	[DefinitionName] ASC,
	[GeoSourceName] ASC,
	[IndicatorSourceCode] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

-- selects, from the factSource file, those rows which contain countries and indicators that we know about (by including them in the DimGeo and DimIndicator tables)
-- INCLUDE countries for which there is no data so that, when a pivot table is created, the countries are laid out with the same spacing
-- for each indicator and source.
-- But EXCLUDE indicators for which there is no data, or there would be too much clutter.

CREATE OR ALTER VIEW [RecognisedFacts]
AS
SELECT
 FactSource.OLTP_FactID,
 FactSource.SourceName,
 DimSource.DimSourceID,
 FactSource.GeoSourceName,
 GeoStandardNames.GeoStandardName,
 FactSource.IndicatorSourceCode as [Fact Indicator Name],
 IndicatorStandardNames.IndicatorSourceCode,
 IndicatorStandardNames.IndicatorStandardName, 
 FactSource.Date,
 FactSource.Value
FROM FactSource
 RIGHT OUTER JOIN GeoStandardNames
 ON FactSource.GeoSourceName = GeoStandardNames.GeoSourceName
 RIGHT OUTER JOIN IndicatorStandardNames
 ON FactSource.SourceName = IndicatorStandardNames.IndicatorSource 
 AND FactSource.IndicatorSourceCode = IndicatorStandardNames.IndicatorSourceCode
 INNER JOIN DimSource
 ON FactSource.SourceName=DimSource.SourceName
WHERE (Year(FactSource.Date) IS NOT NULL) AND (Year(FactSource.Date) > 1700) and (Value<>0)
GO

-- Compresses the rows of the RecognisedFacts view by substituting the integer Indexes of DimGeo and DimIndicator for the actual country and indicator names
-- For debugging purposes only, report on a few additional fields from other dimensions
-- indicator_type is used to split the OLTP fact file into a number of ROLAP fact files for convenient handling, transparency to the user, partitioning, etc.
CREATE OR ALTER VIEW [FactQuery]
AS
SELECT 
 RecognisedFacts.OLTP_FactID,
 RecognisedFacts.SourceName, 
 RecognisedFacts.DimSourceID, 
 RecognisedFacts.Date, 
 RecognisedFacts.Value, 
 DimIndicator.DimIndicatorID, 
 DimGeo.DimGeoID, 
 RecognisedFacts.GeoStandardName, 
 RecognisedFacts.IndicatorStandardName,
 DimIndicator.indicator_type
FROM RecognisedFacts LEFT OUTER JOIN
 DimIndicator ON 
 RecognisedFacts.IndicatorStandardName = DimIndicator.IndicatorStandardName LEFT OUTER JOIN
 DimGeo ON 
 RecognisedFacts.GeoStandardName = DimGeo.GeoStandardName
GO

