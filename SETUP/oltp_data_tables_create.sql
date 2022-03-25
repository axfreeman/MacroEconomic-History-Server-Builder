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

-- selects, from the factSource file, those rows which contain countries and indicators that we know about (by including them in the DimGeo and DimIndicator tables)
-- INCLUDE countries for which there is no data so that, when a pivot table is created, the countries are laid out with the same spacing
-- for each indicator and source.
-- But EXCLUDE indicators for which there is no data, or there would be too much clutter.


-- This view contains all the data associated with the factsource table in a single query
-- Most of the fields are not used, but are included for debugging, testing and inspection

CREATE OR ALTER VIEW [dbo].[FactSourceCompleteView]
AS
SELECT 
       i.StandardisedID,
	   g.GeoStandardisedID,
	   s.DimSourceID,
	   g.GeoPolitical_Type,
       g.GeoStandardName,
       g.ReportingUnit,
       g.GeoEconomic_Region,
       g.Major_Blocs,
       g.Geopolitical_region,
       g.Maddison_availability,
       g.MACROHISTORY_Geography,
       g.WID_Geography,
       g.IMF_main_category,
       g.WEO_Geography,
       i.SourceCode,
       i.StandardCode,
       i.StandardDescription,
       i.IndicatorType,
       i.IndicatorComponent,
       i.Sector,
	   i.AssetType,
       i.accounting_basis,
       i.MeasureType,
       i.MeasureDimension,
       i.MeasureMetric,
       f.Value,
       Year(f.Date) as Year,
       s.SourceName,
       s.SourceNameParent,
       s.SourceNameDetail
FROM dbo.FactSource AS f
    INNER JOIN dbo.IndicatorStandardisedDimensionTable AS i
        ON f.SourceName = i.SourceName
           AND f.IndicatorSourceCode = i.SourceCode
    INNER JOIN dbo.GeoStandardisedDimensionTable AS g
        ON f.GeoSourceName = g.GeoSourceName
    INNER JOIN dbo.DimSource AS s
        ON f.SourceName = s.SourceName
GO