-- Sets up the Relational Tables from which the Cube is built, on the ROLAP server which hosts the cube
-- These tables will be populated from the OLAP server
-- so any changes to the structure of the OLAP tables should be reflected in changes to these tables


USE [MACROHISTORY_ROLAP_220522]
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
 DimGeoStandardisedID int NULL,
 DimIndicatorStandardisedID int NULL,
 Year int Null,
 Value float NULL
 CONSTRAINT PK_FactID PRIMARY KEY CLUSTERED 
  (
   FactID ASC
  )
 ) 
GO


-- New standardised indicator table introduced March 2022. Combines information from what were previously
-- the two separate tables DimIndicator and IndicatorStandardNames

Drop table if exists IndicatorStandardisedDimensionTable
CREATE TABLE [dbo].[IndicatorStandardisedDimensionTable](
	[StandardisedID] [int] NOT NULL,
	[SourceName] [nvarchar](255) NOT NULL, /* was 'IndicatorSource' */
	[SourceCode] [nvarchar](255) NOT NULL, /* was 'IndicatorSourceCode' */
	[SourceDescription] [nvarchar](255) NULL, 
	[StandardCode] [nvarchar](255) NOT NULL, /* was 'IndicatorStandardName, was 256 */
	[StandardDescription][nvarchar](255) NULL, /* new */
	[IndicatorType] [nvarchar](255) NULL, /* was 'indicator_type' */
	[IndicatorComponent][nvarchar](255) NULL, /* New */
	[Sector][nvarchar](255) NULL, /* was 'industrial_sector' */
	[AssetType][nvarchar](255) NULL, /* new */
	[accounting_basis] [nvarchar](255) NULL,
	[MeasureType] [nvarchar](255) NULL, /* was measure_type */
/*	[supplementary] [nvarchar](255) NULL,*/ /* DELETED */
/*	[output_definition] [nvarchar](255) NULL, */ /* DELETED */ 
	[MeasureDimension] [nvarchar](255) NULL, /*was indicator_dimension */
	[MeasureMetric] [nvarchar](255) NULL, /* was indicator_measure */
	[MeasureUnits] [nvarchar](255) NULL, /* was indicator_units */
) ON [PRIMARY]
GO

-- New standardised geography table introduced March 2022. Combines information from what were previously
-- the two separate tables DimGeo and GeoStandardNames

DROP TABLE IF EXISTS [GeoStandardisedDimensionTable]

CREATE TABLE [dbo].[GeoStandardisedDimensionTable](
	[GeoStandardisedID] [int] NOT NULL,
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

-- this query contains a lagged variable so growth can easily be calculated
-- eventually, growth itself will replace this lagged variable

/*CREATE OR ALTER VIEW [dbo].[LaggedFactQuery]
AS


SELECT dbo.FactQuery.FactID, 
 dbo.FactQuery.DimSourceID, 
 dbo.FactQuery.DimGeoID,
 dbo.FactQuery.DimIndicatorID,
 dbo.FactQuery.DateField,
 dbo.FactQuery.Value,
 Fact_1.Value AS LaggedValue,
 dbo.FactQuery.SourceName,
 dbo.FactQuery.SourceNameParent,
 dbo.FactQuery.SourceNameDetail,
 dbo.FactQuery.Description,
 dbo.FactQuery.GeoStandardName, 
 dbo.FactQuery.ReportingUnit,
 dbo.FactQuery.indicator_type,
 dbo.FactQuery.gdp_Expenditure_Component,
 dbo.FactQuery.capital_component,
 dbo.FactQuery.source_component,
 dbo.FactQuery.balance_of_payments_component,
 dbo.FactQuery.population_component,
 dbo.FactQuery.other_indicator_description,
 dbo.FactQuery.output_definition,
 dbo.FactQuery.industrial_sector, 
 dbo.FactQuery.measure_type,
 dbo.FactQuery.indicator_dimension,
 dbo.FactQuery.indicator_units,
 dbo.FactQuery.indicator_metrics
FROM  dbo.FactQuery INNER JOIN
 dbo.Fact AS Fact_1 ON
 YEAR(dbo.FactQuery.DateField) = YEAR(Fact_1.DateField) - 1
 AND dbo.FactQuery.DimSourceID = Fact_1.DimSourceID
 AND dbo.FactQuery.DimGeoID = Fact_1.DimGeoID
 AND dbo.FactQuery.DimIndicatorID = Fact_1.DimIndicatorID
*/

/* newer version of the above

SELECT dbo.FactQuery.FactID, dbo.FactQuery.DateField, dbo.FactQuery.Value, Fact_1.Value AS LaggedValue, dbo.FactQuery.SourceNameDetail, dbo.FactQuery.Description, dbo.FactQuery.GeoStandardName, dbo.FactQuery.ReportingUnit, dbo.FactQuery.indicator_type, dbo.FactQuery.component, 
         dbo.FactQuery.supplementary_information, dbo.FactQuery.output_definition, dbo.FactQuery.industrial_sector, dbo.FactQuery.measure_type, dbo.FactQuery.indicator_dimension, dbo.FactQuery.indicator_units, dbo.FactQuery.indicator_metrics, dbo.FactQuery.IndicatorStandardName, 
         dbo.IndicatorStandardNames.IndicatorSourceDescription, dbo.FactQuery.SourceNameParent, dbo.FactQuery.SourceName, dbo.FactQuery.accounting_basis, dbo.FactQuery.GeoEconomic_Region, dbo.FactQuery.Major_Blocs, dbo.FactQuery.NICS_geography, dbo.FactQuery.Geopolitical_region, 
         dbo.FactQuery.Maddison_availability, dbo.FactQuery.wdi_availability, dbo.FactQuery.penn_availability, dbo.FactQuery.WID_Geography, dbo.FactQuery.IMF_main_category, dbo.FactQuery.MACROHISTORY_Geography, dbo.FactQuery.WEO_Geography, dbo.FactQuery.Size, dbo.FactQuery.GeoPolitical_Type
FROM  dbo.FactQuery INNER JOIN
         dbo.Fact AS Fact_1 ON YEAR(dbo.FactQuery.DateField) = YEAR(Fact_1.DateField) - 1 AND dbo.FactQuery.DimSourceID = Fact_1.DimSourceID AND dbo.FactQuery.DimGeoID = Fact_1.DimGeoID AND dbo.FactQuery.DimIndicatorID = Fact_1.DimIndicatorID LEFT OUTER JOIN
         dbo.IndicatorStandardNames ON dbo.FactQuery.SourceName = dbo.IndicatorStandardNames.IndicatorSource AND dbo.FactQuery.IndicatorStandardName = dbo.IndicatorStandardNames.IndicatorStandardName

GO
*/

CREATE OR ALTER VIEW FactCompleteView

AS

SELECT TOP 100 PERCENT
    s.SourceName as Source,
    s.SourceNameParent as [Dataset],
    s.SourceNameDetail as [Dataset detail],
/*    s.Description, (Additional Information, not useful in this query) */ 
    g.GeoPolitical_Type as [Geopolitical type],
    g.Major_Blocs as [Bloc],
    g.GeoEconomic_Region as [Geo-economic region],
    g.IMF_main_category as [IMF geoeconomic classification],
    g.ReportingUnit as [Reporting Unit],
    g.GeoStandardName as Country ,
/*    g.Geopolitical_region, redundant, probably delete this */
    g.Maddison_availability,
    g.wdi_availability,
    g.penn_availability,
/*     g.MACROHISTORY_Geography, */
/*    g.WID_Geography, */
/*    g.WEO_Geography, */
/*    g.Size, */
/*    g.GeoSourceName, */
/*    i.IndicatorStandardName,*/
	i.SourceCode,
    i.SourceDescription,
	i.StandardCode,
	i.StandardDescription,
    i.IndicatorType as [Indicator type],
	i.IndicatorComponent as [Indicator Component or Detail],
    i.Sector as [Industrial or Social Sector],
	i.AssetType as [Asset Type],
    i.accounting_basis as [GDP measure],
    i.MeasureType as [Measure Type],
    i.MeasureDimension as [Measure Dimension],
    i.MeasureMetric as [Measure Metric],
	i.MeasureUnits as [Measure Units],
    f.Year,
    f.Value
FROM dbo.Fact AS f
    INNER JOIN dbo.DimSource AS s
        ON f.DimSourceID = s.DimSourceID
    INNER JOIN dbo.GeoStandardisedDimensionTable AS g
        ON f.DimGeoStandardisedID = g.GeoStandardisedID
    INNER JOIN dbo.IndicatorStandardisedDimensionTable AS i
        ON f.DimIndicatorStandardisedID = i.StandardisedID
ORDER BY s.SourceName,
         i.IndicatorType,
         g.Major_Blocs,
         g.ReportingUnit

GO
