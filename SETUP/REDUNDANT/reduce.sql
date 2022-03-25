Use MACROHISTORY_ROLAP
GO

CREATE or alter VIEW [dbo].[smallerIndicatorView]
AS
SELECT a.IndicatorStandardName,
       a.indicator_type,
       a.component AS component_description,
       a.supplementary_information,
       a.output_definition,
       a.accounting_basis,
       a.industrial_sector,
       a.measure_type,
       a.indicator_dimension,
       a.indicator_units,
       a.indicator_metrics,
       a.IndicatorSource,
       a.IndicatorSourceDescription,
       a.IndicatorSourceCode,
       a.SourceName,
       a.SourceNameParent,
       a.SourceNameDetail,
       a.Description,
       a.SIndID
FROM dbo.simplifiedIndicatorTable AS a
    INNER JOIN dbo.FilterCompositeTable AS b
        ON a.SourceNameParent = b.SourceNameParent

           AND a.indicator_type = b.indicator_type
		   AND a.component=b.component
           AND ISNULL(a.output_definition, N'AAA') = b.output_definition

GO


drop table if exists dbo.smallerIndicatorTable
select *
into smallerIndicatorTable
from [smallerIndicatorView]

go

CREATE or ALTER VIEW [dbo].[SmallGeographyView]
AS
SELECT GeoPolitical_Type,
       DimGeoID,
       GeoStandardName,
       ReportingUnit,
       Size,
       GeoEconomic_Region,
       Major_Blocs,
       NICS_geography,
       Geopolitical_region,
       Maddison_availability,
       wdi_availability,
       penn_availability,
       MACROHISTORY_Geography,
       WID_Geography,
       IMF_main_category,
       WEO_Geography
FROM dbo.DimGeo
WHERE (GeoPolitical_Type = N'Nation')
GO

drop table if exists dbo.smallerGeographyTable
select *
into smallerGeographyTable
from [SmallGeographyView]

GO

CREATE or alter VIEW [dbo].[smallerFactView]
AS
SELECT a.Year,
       a.DimGeoID,
       a.Value,
       a.SIndID
FROM dbo.simplifiedFactTable AS a
    INNER JOIN dbo.smallerIndicatorTable AS b
        ON a.SIndID = b.SIndID
    INNER JOIN dbo.smallerGeographyTable
        ON a.DimGeoID = dbo.smallerGeographyTable.DimGeoID
GO




drop table if exists dbo.smallerFactTable
select *
into smallerFactTable
from [smallerFactView]
GO

CREATE or alter VIEW [dbo].[smallCompleteQuery]
AS
SELECT c.GeoPolitical_Type,
       c.DimGeoID,
       c.GeoStandardName,
       c.ReportingUnit,
       c.Size,
       c.GeoEconomic_Region,
       c.Major_Blocs,
       c.NICS_geography,
       c.Geopolitical_region,
       c.Maddison_availability,
       c.wdi_availability,
       c.penn_availability,
       c.MACROHISTORY_Geography,
       c.WID_Geography,
       c.IMF_main_category,
       c.WEO_Geography,
       b.IndicatorStandardName,
       b.indicator_type,
       b.component_description,
       b.supplementary_information,
       b.output_definition,
       b.accounting_basis,
       b.industrial_sector,
       b.measure_type,
       b.indicator_dimension,
       b.indicator_units,
       b.indicator_metrics,
       b.IndicatorSource,
       b.IndicatorSourceDescription,
       b.IndicatorSourceCode,
       b.SourceNameDetail,
       b.Description,
       b.SIndID
FROM dbo.smallerFactTable AS a
    RIGHT OUTER JOIN dbo.smallerIndicatorTable AS b
        ON a.SIndID = b.SIndID
    RIGHT OUTER JOIN dbo.smallerGeographyTable AS c
        ON a.DimGeoID = c.DimGeoID
GO