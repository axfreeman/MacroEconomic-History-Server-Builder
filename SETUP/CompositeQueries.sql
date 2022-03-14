use macrohistory_rolap
GO

CREATE or ALTER view LaggedFactQuery
AS

SELECT fact.FactID,
       fact.DateField,
       fact.Value,
       Fact_1.Value AS LaggedValue,
       fact.SourceNameDetail,
       fact.Description,
       fact.GeoStandardName,
       fact.ReportingUnit,
       fact.indicator_type,
       fact.component,
       fact.supplementary_information,
       fact.output_definition,
       fact.industrial_sector,
       fact.measure_type,
       fact.indicator_dimension,
       fact.indicator_units,
       fact.indicator_metrics,
       fact.IndicatorStandardName,
       i.IndicatorSourceDescription,
       fact.SourceNameParent,
       fact.SourceName,
       fact.accounting_basis,
       fact.GeoEconomic_Region,
       fact.Major_Blocs,
       fact.NICS_geography,
       fact.Geopolitical_region,
       fact.Maddison_availability,
       fact.wdi_availability,
       fact.penn_availability,
       fact.WID_Geography,
       fact.IMF_main_category,
       fact.MACROHISTORY_Geography,
       fact.WEO_Geography,
       fact.Size,
       fact.GeoPolitical_Type
FROM dbo.FactQuery AS fact
    INNER JOIN dbo.Fact AS Fact_1
        ON YEAR(fact.DateField) = YEAR(Fact_1.DateField) - 1
           AND fact.DimSourceID = Fact_1.DimSourceID
           AND fact.DimGeoID = Fact_1.DimGeoID
           AND fact.DimIndicatorID = Fact_1.DimIndicatorID
    LEFT OUTER JOIN dbo.IndicatorStandardNames AS i
        ON fact.SourceName = i.IndicatorSource
           AND fact.IndicatorStandardName = i.IndicatorStandardName
GO
Create or alter view FactWithGeographyView
AS

SELECT geo.Major_Blocs,
       fact.FactID,
       fact.Value,
       fact.DimIndicatorID as SIndID,
       geo.ReportingUnit,
       geo.GeoStandardName,
       geo.wdi_availability,
       geo.penn_availability,
       geo.GeoEconomic_Region,
       YEAR(fact.DateField) AS year
FROM dbo.Fact AS fact
    INNER JOIN dbo.DimGeo AS geo
        ON fact.DimGeoID = geo.DimGeoID