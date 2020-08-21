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

-- create a generic pivoted table that source data can be read into, prior to unpivoting
-- use 'Try block' rather than DROP IF EXISTS for backwards compatibility with SQLServer 2014

DROP TABLE IF EXISTS PivotedSources
GO

CREATE TABLE [PivotedSources](
 [SourceName][nvarchar](50) NOT NULL,
 [DefinitionName] [nvarchar] (50) NOT NULL,
 [GeoSourceName] [nvarchar](255) NULL,
 [IndicatorSourceName] [nvarchar](255) NULL,  /* I think this field is redundant AF 19/3/2020 */
 [IndicatorSourceCode] [nvarchar](255) not NULL,
 [1925] [float] NULL,
 [1926] [float] NULL,
 [1927] [float] NULL,
 [1928] [float] NULL,
 [1929] [float] NULL,
 [1930] [float] NULL,
 [1931] [float] NULL,
 [1932] [float] NULL,
 [1933] [float] NULL,
 [1934] [float] NULL,
 [1935] [float] NULL,
 [1936] [float] NULL,
 [1937] [float] NULL,
 [1938] [float] NULL,
 [1939] [float] NULL,
 [1940] [float] NULL,
 [1941] [float] NULL,
 [1942] [float] NULL,
 [1943] [float] NULL,
 [1944] [float] NULL,
 [1945] [float] NULL,
 [1946] [float] NULL,
 [1947] [float] NULL,
 [1948] [float] NULL,
 [1949] [float] NULL,
 [1950] [float] NULL,
 [1951] [float] NULL,
 [1952] [float] NULL,
 [1953] [float] NULL,
 [1954] [float] NULL,
 [1955] [float] NULL,
 [1956] [float] NULL,
 [1957] [float] NULL,
 [1958] [float] NULL,
 [1959] [float] NULL,
 [1960] [float] NULL,
 [1961] [float] NULL,
 [1962] [float] NULL,
 [1963] [float] NULL,
 [1964] [float] NULL,
 [1965] [float] NULL,
 [1966] [float] NULL,
 [1967] [float] NULL,
 [1968] [float] NULL,
 [1969] [float] NULL,
 [1970] [float] NULL,
 [1971] [float] NULL,
 [1972] [float] NULL,
 [1973] [float] NULL,
 [1974] [float] NULL,
 [1975] [float] NULL,
 [1976] [float] NULL,
 [1977] [float] NULL,
 [1978] [float] NULL,
 [1979] [float] NULL,
 [1980] [float] NULL,
 [1981] [float] NULL,
 [1982] [float] NULL,
 [1983] [float] NULL,
 [1984] [float] NULL,
 [1985] [float] NULL,
 [1986] [float] NULL,
 [1987] [float] NULL,
 [1988] [float] NULL,
 [1989] [float] NULL,
 [1990] [float] NULL,
 [1991] [float] NULL,
 [1992] [float] NULL,
 [1993] [float] NULL,
 [1994] [float] NULL,
 [1995] [float] NULL,
 [1996] [float] NULL,
 [1997] [float] NULL,
 [1998] [float] NULL,
 [1999] [float] NULL,
 [2000] [float] NULL,
 [2001] [float] NULL,
 [2002] [float] NULL,
 [2003] [float] NULL,
 [2004] [float] NULL,
 [2005] [float] NULL,
 [2006] [float] NULL,
 [2007] [float] NULL,
 [2008] [float] NULL,
 [2009] [float] NULL,
 [2010] [float] NULL,
 [2011] [float] NULL,
 [2012] [float] NULL,
 [2013] [float] NULL,
 [2014] [float] NULL,
 [2015] [float] NULL,
 [2016] [float] NULL,
 [2017] [float] NULL,
 [2018] [float] NULL,
 [2019] [float] NULL
) ON [PRIMARY]
GO


-- Macrofinancial History database requires specific treatment
-- listed variables are year	country	iso	ifs	pop	rgdpmad	rgdppc	rconpc	gdp	iy	cpi	ca	imports	exports	narrowm	money	stir	ltrate	stocks	debtgdp	revenue	expenditure	xrusd	crisisJST	tloans	tmort	thh	tbus	hpnom

DROP TABLE IF EXISTS MacroFinancialHistory
GO

CREATE TABLE [MacroFinancialHistory](
 [SourceName] [nvarchar](50) NOT NULL,
 [DefinitionName] [nvarchar] (50) NOT NULL,
 year NVARCHAR(4),
 country NVARCHAR (255), 
 pop [float],
 rgdpmad [float],
 rgdppc [float],
 gdp [float],
 rconpc [float],
 cpi [float],
 ca [float],
 imports [float],
 exports [float],
 narrowm [float],
 money [float],
 stir [float],
 ltrate [float],
 stocks [float],
 debtgdp [float],
 revenue [float],
 expenditure [float],
 xrusd [float],
 crisisJST [float],
 tloans [float],
 tmort [float],
 thh [float],
 tbus [float],
 hpnom [float]
) ON [PRIMARY]
GO

-- Penn_NA database requires specific treatment
-- listed variables are year	v_c	v_i	v_g	v_x	v_m	v_gdp	q_c	q_i	q_g	q_x	q_m	q_gdp	pop	xr	xr2	v_gfcf	q_gfcf	emp	avh

DROP TABLE IF EXISTS Penn_NA
GO

CREATE TABLE [Penn_NA](
CountryCode Nvarchar(3) NOT NULL,
[SourceName] [nvarchar](50) NOT NULL,
[DefinitionName] [nvarchar] (50) NOT NULL,
Year int NULL,
v_c float NULL,
v_i float NULL,
v_g float NULL,
v_x float NULL,
v_m float NULL,
v_gdp float NULL,
q_c float NULL,
q_i float NULL,
q_g float NULL,
q_x float NULL,
q_m float NULL,
q_gdp float NULL,
pop float NULL,
xr float NULL,
xr2 float NULL,
v_gfcf float NULL,
q_gfcf float NULL,
emp float NULL,
avh float NULL
)
GO
 

-- Penn full database requires specific treatment

DROP TABLE IF EXISTS Penn
GO
CREATE  TABLE [Penn](
CountryCode Nvarchar(3) NOT NULL,
[SourceName] [nvarchar](50) NOT NULL,
[DefinitionName] [nvarchar] (50) NOT NULL,
Year int NULL,
ccon float NULL,
cda float NULL,
cgdpe float NULL,
cgdpo float NULL,
ck float NULL,
xr float NULL,
rgdpna float NULL,
rconna float NULL,
rdana float NULL,
rkna float NULL,
labsh float NULL,
delta float NULL,
rgdpe float NULL,
rgdpo float NULL,
pop float NULL,
emp float NULL,
avh float NULL
)
GO
 

 
-- The FactSource file amalgamates data from all the various sources in a standard form.
-- Alphanumeric names are used for the Geo, Indicator and Quantifier fields.
-- it is then optimised by the 'FactStandardQuery' view, which substitutes integer primary keys 
-- for these alphanumeric fields. 
-- When the ROLAP server is initialised, the FactStandardQuery is coped to the ROLAP server.

DROP TABLE IF EXISTS FactSource
GO
CREATE TABLE [FactSource](
 [OLTP_FactID] bigint not null IDENTITY (1,1), /* this key isn't used but helps track and debug problem rows */
 [SourceName] [nvarchar](50) NULL, /* the source is a single provider at a single release date, eg UN2018, WB2015*/
 [DefinitionName] nvarchar(50)NULL, /* the 'definition' is a selection of records from different providers. Initially, the selection for a given source will simply be the source */
 [GeoSourceName] [nvarchar](255) NULL,
	-- Abbreviated complete description of the indicator and its quantifier, EG GDP-USD-MER, Exports, Population
	-- Gets reduced to integer PK when imported into ROLAP 
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



-- restrict the rows of StandardisedPivotedSources which are unpivoted into FactSource, to prevent bloat.
-- only use those rows which have indicators that will be included in the final dataset.

CREATE OR ALTER VIEW [StandardisedPivotedSources]
AS
SELECT dbo.PivotedSources.*
FROM dbo.PivotedSources INNER JOIN
 dbo.IndicatorStandardNames ON 
 dbo.PivotedSources.IndicatorSourceCode = dbo.IndicatorStandardNames.IndicatorSourceCode AND
 dbo.PivotedSources.SourceName = dbo.IndicatorStandardNames.IndicatorSource
GO