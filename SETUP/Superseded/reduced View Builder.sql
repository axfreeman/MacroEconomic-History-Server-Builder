 
 
CREATE OR ALTER VIEW [dbo].[Project_1_reduced]
AS
  SELECT factid,
         dimsourceid,
         dimdefinitionid,
         dimgeoid,
         dimindicatorid,
         year,
         yearasdate,
         value,
         definitionname
  FROM   dbo.factquery
  WHERE  ( type = N'Demography and Labour' )
         AND ( indicator = N'Population' )
         AND ( definitionname = N'CLEANED' )
          OR ( type = N'GDP Measures' )
             AND ( indicator = N'GDP Total' )

GO
 
CREATE OR ALTER VIEW [dbo].[Project3_fact_query]
AS
  SELECT factid,
         dimsourceid,
         dimdefinitionid,
         dimgeoid,
         dimindicatorid,
         yearasdate,
         value,
  FROM   dbo.factquery
  WHERE  ( sourcename = N'PENN'
            OR sourcename = N'WDI2018' )
         AND ( measure = N'USD Current'
                OR measure = N'PPP Current'
                OR measure = N'Persons' )
         AND ( indicator = N'GDP Total'
                OR indicator = N'Population' )

go

CREATE OR ALTER VIEW [dbo].[Project3_source_query]
AS
  SELECT dimsourceid,
         sourcenameparent,
         description,
         sourcenamedetail,
         dataoriginfile,
         preparationnotes,
         sourcenotes,
         datanotes,
         sourcename
  FROM   dbo.dimsource
  WHERE  ( sourcename = N'PENN'
            OR sourcename = N'WDI2018' )

go  

CREATE OR ALTER VIEW [dbo].[Project3_indicator_query]
AS
  SELECT dimindicatorid,
         indicatorstandardname,
         indicator,
         measure
  FROM   dbo.dimindicator
  WHERE  ( indicatorstandardname = N'Population'
            OR indicatorstandardname = N'GDP-TOTAL-USD-CURRENT'
            OR indicatorstandardname = N'GDP-TOTAL-PPP-CURRENT' )

go  


CREATE OR ALTER VIEW [dbo].[Project3_all_data_query]
AS
  SELECT dbo.project3_indicator_query.dimindicatorid,
         dbo.project3_source_query.dimsourceid,
         dbo.project3_fact_query.year,
         dbo.project3_fact_query.value,
         dbo.project3_indicator_query.indicator,
         dbo.project3_source_query.sourcename,
         dbo.dimgeo.geostandardname,
         dbo.dimgeo.geopolitical_type,
         dbo.dimgeo.reportingunit,
         dbo.dimgeo.size,
         dbo.dimgeo.geoeconomic_region,
         dbo.dimgeo.geopolitical_region,
         dbo.dimgeo.penn_geography,
         dbo.dimgeo.wid_geography,
         dbo.dimgeo.imf_main_category,
         dbo.dimgeo.imf_sub_category,
         dbo.dimdefinitions.definitionname
  FROM   dbo.project3_fact_query
         LEFT OUTER JOIN dbo.dimdate
                      ON dbo.project3_fact_query.yearasdate = dbo.dimdate.date
         LEFT OUTER JOIN dbo.dimgeo
                      ON dbo.project3_fact_query.dimgeoid = dbo.dimgeo.dimgeoid
         LEFT OUTER JOIN dbo.dimdefinitions
                      ON dbo.project3_fact_query.dimdefinitionid =
                         dbo.dimdefinitions.dimdefinitionid
         LEFT OUTER JOIN dbo.project3_source_query
                      ON dbo.project3_fact_query.dimsourceid =
                         dbo.project3_source_query.dimsourceid
         LEFT OUTER JOIN dbo.project3_indicator_query
                      ON dbo.project3_fact_query.dimindicatorid =
                         dbo.project3_indicator_query.dimindicatorid

go  

CREATE OR ALTER VIEW FactQueryCapitalStock 
AS
SELECT FactID, DimSourceID, DimDefinitionID, DimGeoID, DimIndicatorID, DateField, Value
FROM FactQuery
WHERE (Type = N'GDP Measures' OR
 Type = N'Capital' OR
 Type = N'GDP Components' OR
 Type = N'Demography and Labour' OR
 Type = N'Indices') AND (SourceName = 'UN2018' OR
 SourceName = 'MADDISON' OR
 SourceName = 'MACROHIST' OR
 SourceName = 'BARRO-URSUA' OR
		 SourceName='Eurostat' OR
 SourceName = 'PENN' OR
 SourceName = 'OECD')
GO

