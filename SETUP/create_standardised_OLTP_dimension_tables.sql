Use MACROHISTORY_OLTP

drop table if exists dbo.GeoStandardisedDimensionTable
select *
into GeoStandardisedDimensionTable
from [GeoStandardisedDimensionView]

go


ALTER TABLE GeoStandardisedDimensionTable ADD GeoStandardisedID INT IDENTITY(1, 1)

go

drop table if exists dbo.IndicatorStandardisedDimensionTable
select *
into IndicatorStandardisedDimensionTable
from [IndicatorStandardisedDimensionView]

go


ALTER TABLE IndicatorStandardisedDimensionTable ADD IndicatorStandardisedID INT IDENTITY(1, 1)

go

--This view contains all the data associated with the factsource table in a single query

CREATE OR ALTER VIEW [dbo].[FactSourceCompleteView]
AS
SELECT 
       i.IndicatorStandardisedID,
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
       i.IndicatorStandardName,
       i.IndicatorSourceDescription,
       i.indicator_type,
       i.component,
       i.accounting_basis,
       i.industrial_sector,
       i.measure_type,
       i.supplementary,
       i.output_definition,
       i.indicator_dimension,
       i.indicator_metrics,
       i.IndicatorSourceCode,
       f.Value,
       Year(f.Date) as Year,
       s.SourceName,
       s.SourceNameParent,
       s.SourceNameDetail
FROM dbo.FactSource AS f
    INNER JOIN dbo.IndicatorStandardisedDimensionTable AS i
        ON f.SourceName = i.IndicatorSource
           AND f.IndicatorSourceCode = i.IndicatorSourceCode
    INNER JOIN dbo.GeoStandardisedDimensionTable AS g
        ON f.GeoSourceName = g.GeoSourceName
    INNER JOIN dbo.DimSource AS s
        ON f.SourceName = s.SourceName
GO
