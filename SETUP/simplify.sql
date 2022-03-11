Use MACROHISTORY_ROLAP
GO

CREATE or alter VIEW [dbo].[simplifiedIndicatorView]
AS
SELECT c.IndicatorStandardName,
       c.indicator_type,
       c.component,
       c.supplementary_information,
       c.output_definition,
       c.accounting_basis,
       c.industrial_sector,
       c.measure_type,
       c.indicator_dimension,
       c.indicator_units,
       c.indicator_metrics,
       b.IndicatorSource,
       b.IndicatorSourceDescription,
       b.IndicatorSourceCode,
       a.SourceNameDetail,
       a.Description,
       c.DimIndicatorID,
       a.DimSourceID,
       a.SourceName,
       a.SourceNameParent
FROM dbo.DimSource AS a
    RIGHT OUTER JOIN dbo.IndicatorStandardNames AS b
        ON a.SourceName = b.IndicatorSource
    RIGHT OUTER JOIN dbo.DimIndicator AS c
        ON b.IndicatorStandardName = c.IndicatorStandardName
GO

drop table if exists dbo.simplifiedIndicatorTable
select *
into simplifiedIndicatorTable
from simplifiedIndicatorView

go

ALTER TABLE simplifiedIndicatorTable ADD SIndID INT IDENTITY(1, 1)

go

Use MACROHISTORY_ROLAP
GO

CREATE OR ALTER VIEW [dbo].[simplifiedFactView]
AS
SELECT Year(dbo.Fact.DateField) as Year,

       dbo.Fact.Value,
       dbo.Fact.DimGeoID,
       simplifiedIndicatorTable.SIndID
FROM dbo.simplifiedIndicatorTable
    RIGHT OUTER JOIN dbo.Fact
        ON dbo.simplifiedIndicatorTable.DimIndicatorID = dbo.Fact.DimIndicatorID
           AND dbo.simplifiedIndicatorTable.DimSourceID = dbo.Fact.DimSourceID
GO

drop table if exists dbo.simplifiedFactTable
select *
into simplifiedFactTable
from [simplifiedFactView]

GO
