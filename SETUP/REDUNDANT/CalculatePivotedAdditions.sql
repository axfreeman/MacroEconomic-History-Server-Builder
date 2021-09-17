-- Add some calculated rows to PivotedSources to create USD GDP values 
-- by multiplying GDP and the period average exchange rate
-- We do this here at ELT time rather than using DAX or MDX calculated fields
-- so that the result does not depend on Cube technology and can be exported,
-- should the need arise, as simple tables for use in non-Cube-based applications

USE macrohistory_oltp

-- Used to precalculate USD values of GDP using the exchange rate
-- The reason this is done here with the unpivoted IFS source is that we don't have to use DAX or MDX
-- queries to calculate the fields involved, so they can be exported from the ROLAP server to an ordinary spreadsheet

BEGIN TRY 
DROP VIEW [dbo].[PivotedUSD_GDP] 
END TRY 
BEGIN CATCH
END CATCH 
GO

CREATE VIEW [dbo].[PivotedUSD_GDP]
AS
SELECT 
dbo.PivotedSources.SourceName, 
dbo.PivotedSources.DefinitionName, 
dbo.PivotedSources.GeoSourceName, 
N'GDP Total USD Calculated' as IndicatorSourceName,
N'NGDP_XDC*EDNA_USD_XDC_RATE' as IndicatorSourceCode 
, dbo.PivotedSources.[1946]*PivotedSources_1.[1946] AS [1946]
, dbo.PivotedSources.[1947]*PivotedSources_1.[1947] AS [1947]
, dbo.PivotedSources.[1948]*PivotedSources_1.[1948] AS [1948]
, dbo.PivotedSources.[1949]*PivotedSources_1.[1949] AS [1949]
, dbo.PivotedSources.[1950]*PivotedSources_1.[1950] AS [1950]
, dbo.PivotedSources.[1951]*PivotedSources_1.[1951] AS [1951]
, dbo.PivotedSources.[1952]*PivotedSources_1.[1952] AS [1952]
, dbo.PivotedSources.[1953]*PivotedSources_1.[1953] AS [1953]
, dbo.PivotedSources.[1954]*PivotedSources_1.[1954] AS [1954]
, dbo.PivotedSources.[1955]*PivotedSources_1.[1955] AS [1955]
, dbo.PivotedSources.[1956]*PivotedSources_1.[1956] AS [1956]
, dbo.PivotedSources.[1957]*PivotedSources_1.[1957] AS [1957]
, dbo.PivotedSources.[1958]*PivotedSources_1.[1958] AS [1958]
, dbo.PivotedSources.[1959]*PivotedSources_1.[1959] AS [1959]
, dbo.PivotedSources.[1960]*PivotedSources_1.[1960] AS [1960]
, dbo.PivotedSources.[1961]*PivotedSources_1.[1961] AS [1961]
, dbo.PivotedSources.[1962]*PivotedSources_1.[1962] AS [1962]
, dbo.PivotedSources.[1963]*PivotedSources_1.[1963] AS [1963]
, dbo.PivotedSources.[1964]*PivotedSources_1.[1964] AS [1964]
, dbo.PivotedSources.[1965]*PivotedSources_1.[1965] AS [1965]
, dbo.PivotedSources.[1966]*PivotedSources_1.[1966] AS [1966]
, dbo.PivotedSources.[1967]*PivotedSources_1.[1967] AS [1967]
, dbo.PivotedSources.[1968]*PivotedSources_1.[1968] AS [1968]
, dbo.PivotedSources.[1969]*PivotedSources_1.[1969] AS [1969]
, dbo.PivotedSources.[1970]*PivotedSources_1.[1970] AS [1970]
, dbo.PivotedSources.[1971]*PivotedSources_1.[1971] AS [1971]
, dbo.PivotedSources.[1972]*PivotedSources_1.[1972] AS [1972]
, dbo.PivotedSources.[1973]*PivotedSources_1.[1973] AS [1973]
, dbo.PivotedSources.[1974]*PivotedSources_1.[1974] AS [1974]
, dbo.PivotedSources.[1975]*PivotedSources_1.[1975] AS [1975]
, dbo.PivotedSources.[1976]*PivotedSources_1.[1976] AS [1976]
, dbo.PivotedSources.[1977]*PivotedSources_1.[1977] AS [1977]
, dbo.PivotedSources.[1978]*PivotedSources_1.[1978] AS [1978]
, dbo.PivotedSources.[1979]*PivotedSources_1.[1979] AS [1979]
, dbo.PivotedSources.[1980]*PivotedSources_1.[1980] AS [1980]
, dbo.PivotedSources.[1981]*PivotedSources_1.[1981] AS [1981]
, dbo.PivotedSources.[1982]*PivotedSources_1.[1982] AS [1982]
, dbo.PivotedSources.[1983]*PivotedSources_1.[1983] AS [1983]
, dbo.PivotedSources.[1985]*PivotedSources_1.[1984] AS [1984]
, dbo.PivotedSources.[1984]*PivotedSources_1.[1985] AS [1985]
, dbo.PivotedSources.[1986]*PivotedSources_1.[1986] AS [1986]
, dbo.PivotedSources.[1987]*PivotedSources_1.[1987] AS [1987]
, dbo.PivotedSources.[1988]*PivotedSources_1.[1988] AS [1988]
, dbo.PivotedSources.[1989]*PivotedSources_1.[1989] AS [1989]
, dbo.PivotedSources.[1990]*PivotedSources_1.[1990] AS [1990]
, dbo.PivotedSources.[1991]*PivotedSources_1.[1991] AS [1991]
, dbo.PivotedSources.[1992]*PivotedSources_1.[1992] AS [1992]
, dbo.PivotedSources.[1993]*PivotedSources_1.[1993] AS [1993]
, dbo.PivotedSources.[1994]*PivotedSources_1.[1994] AS [1994]
, dbo.PivotedSources.[1995]*PivotedSources_1.[1995] AS [1995]
, dbo.PivotedSources.[1996]*PivotedSources_1.[1996] AS [1996]
, dbo.PivotedSources.[1997]*PivotedSources_1.[1997] AS [1997]
, dbo.PivotedSources.[1998]*PivotedSources_1.[1998] AS [1998]
, dbo.PivotedSources.[1999]*PivotedSources_1.[1999] AS [1999]
, dbo.PivotedSources.[2000]*PivotedSources_1.[2000] AS [2000]
, dbo.PivotedSources.[2001]*PivotedSources_1.[2001] AS [2001]
, dbo.PivotedSources.[2002]*PivotedSources_1.[2002] AS [2002]
, dbo.PivotedSources.[2003]*PivotedSources_1.[2003] AS [2003]
, dbo.PivotedSources.[2004]*PivotedSources_1.[2004] AS [2004]
, dbo.PivotedSources.[2005]*PivotedSources_1.[2005] AS [2005]
, dbo.PivotedSources.[2006]*PivotedSources_1.[2006] AS [2006]
, dbo.PivotedSources.[2007]*PivotedSources_1.[2007] AS [2007]
, dbo.PivotedSources.[2008]*PivotedSources_1.[2008] AS [2008]
, dbo.PivotedSources.[2009]*PivotedSources_1.[2009] AS [2009]
, dbo.PivotedSources.[2010]*PivotedSources_1.[2010] AS [2010]
, dbo.PivotedSources.[2011]*PivotedSources_1.[2011] AS [2011]
, dbo.PivotedSources.[2012]*PivotedSources_1.[2012] AS [2012]
, dbo.PivotedSources.[2013]*PivotedSources_1.[2013] AS [2013]
, dbo.PivotedSources.[2014]*PivotedSources_1.[2014] AS [2014]
, dbo.PivotedSources.[2015]*PivotedSources_1.[2015] AS [2015]
, dbo.PivotedSources.[2016]*PivotedSources_1.[2016] AS [2016]
, dbo.PivotedSources.[2017]*PivotedSources_1.[2017] AS [2017]
FROM dbo.PivotedSources LEFT OUTER JOIN
 dbo.PivotedSources AS PivotedSources_1 ON 
 dbo.PivotedSources.SourceName = PivotedSources_1.SourceName AND 
 dbo.PivotedSources.DefinitionName = PivotedSources_1.DefinitionName AND 
 dbo.PivotedSources.GeoSourceName = PivotedSources_1.GeoSourceName
WHERE
(dbo.PivotedSources.SourceName = N'IFS2018') AND 
(dbo.PivotedSources.IndicatorSourceCode = N'NGDP_XDC') AND 
(PivotedSources_1.IndicatorSourceCode = N'EDNA_USD_XDC_RATE')
GO

-- Used to precalculate USD values of GDP using the exchange rate.
-- Same as PivotedUSD_GDP except for the seasonally-adjusted GDP series.
-- This is because six countries (NZ,Oz,Canada,US,Mexico) supply IFS with Seasonally-adjusted data that starts
-- earlier than the unadjusted data.

BEGIN TRY 
DROP VIEW [dbo].[PivotedUSD_GDP_SA] 
END TRY 
BEGIN CATCH
END CATCH 
GO

CREATE VIEW [dbo].[PivotedUSD_GDP_SA]
AS
SELECT 
dbo.PivotedSources.SourceName, 
dbo.PivotedSources.DefinitionName, 
dbo.PivotedSources.GeoSourceName, 
N'GDP Total USD SA Calculated' as IndicatorSourceName,
N'NGDP_XDC_SA*EDNA_USD_XDC_RATE' as IndicatorSourceCode 
, dbo.PivotedSources.[1946]*PivotedSources_1.[1946] AS [1946]
, dbo.PivotedSources.[1947]*PivotedSources_1.[1947] AS [1947]
, dbo.PivotedSources.[1948]*PivotedSources_1.[1948] AS [1948]
, dbo.PivotedSources.[1949]*PivotedSources_1.[1949] AS [1949]
, dbo.PivotedSources.[1950]*PivotedSources_1.[1950] AS [1950]
, dbo.PivotedSources.[1951]*PivotedSources_1.[1951] AS [1951]
, dbo.PivotedSources.[1952]*PivotedSources_1.[1952] AS [1952]
, dbo.PivotedSources.[1953]*PivotedSources_1.[1953] AS [1953]
, dbo.PivotedSources.[1954]*PivotedSources_1.[1954] AS [1954]
, dbo.PivotedSources.[1955]*PivotedSources_1.[1955] AS [1955]
, dbo.PivotedSources.[1956]*PivotedSources_1.[1956] AS [1956]
, dbo.PivotedSources.[1957]*PivotedSources_1.[1957] AS [1957]
, dbo.PivotedSources.[1958]*PivotedSources_1.[1958] AS [1958]
, dbo.PivotedSources.[1959]*PivotedSources_1.[1959] AS [1959]
, dbo.PivotedSources.[1960]*PivotedSources_1.[1960] AS [1960]
, dbo.PivotedSources.[1961]*PivotedSources_1.[1961] AS [1961]
, dbo.PivotedSources.[1962]*PivotedSources_1.[1962] AS [1962]
, dbo.PivotedSources.[1963]*PivotedSources_1.[1963] AS [1963]
, dbo.PivotedSources.[1964]*PivotedSources_1.[1964] AS [1964]
, dbo.PivotedSources.[1965]*PivotedSources_1.[1965] AS [1965]
, dbo.PivotedSources.[1966]*PivotedSources_1.[1966] AS [1966]
, dbo.PivotedSources.[1967]*PivotedSources_1.[1967] AS [1967]
, dbo.PivotedSources.[1968]*PivotedSources_1.[1968] AS [1968]
, dbo.PivotedSources.[1969]*PivotedSources_1.[1969] AS [1969]
, dbo.PivotedSources.[1970]*PivotedSources_1.[1970] AS [1970]
, dbo.PivotedSources.[1971]*PivotedSources_1.[1971] AS [1971]
, dbo.PivotedSources.[1972]*PivotedSources_1.[1972] AS [1972]
, dbo.PivotedSources.[1973]*PivotedSources_1.[1973] AS [1973]
, dbo.PivotedSources.[1974]*PivotedSources_1.[1974] AS [1974]
, dbo.PivotedSources.[1975]*PivotedSources_1.[1975] AS [1975]
, dbo.PivotedSources.[1976]*PivotedSources_1.[1976] AS [1976]
, dbo.PivotedSources.[1977]*PivotedSources_1.[1977] AS [1977]
, dbo.PivotedSources.[1978]*PivotedSources_1.[1978] AS [1978]
, dbo.PivotedSources.[1979]*PivotedSources_1.[1979] AS [1979]
, dbo.PivotedSources.[1980]*PivotedSources_1.[1980] AS [1980]
, dbo.PivotedSources.[1981]*PivotedSources_1.[1981] AS [1981]
, dbo.PivotedSources.[1982]*PivotedSources_1.[1982] AS [1982]
, dbo.PivotedSources.[1983]*PivotedSources_1.[1983] AS [1983]
, dbo.PivotedSources.[1985]*PivotedSources_1.[1984] AS [1984]
, dbo.PivotedSources.[1984]*PivotedSources_1.[1985] AS [1985]
, dbo.PivotedSources.[1986]*PivotedSources_1.[1986] AS [1986]
, dbo.PivotedSources.[1987]*PivotedSources_1.[1987] AS [1987]
, dbo.PivotedSources.[1988]*PivotedSources_1.[1988] AS [1988]
, dbo.PivotedSources.[1989]*PivotedSources_1.[1989] AS [1989]
, dbo.PivotedSources.[1990]*PivotedSources_1.[1990] AS [1990]
, dbo.PivotedSources.[1991]*PivotedSources_1.[1991] AS [1991]
, dbo.PivotedSources.[1992]*PivotedSources_1.[1992] AS [1992]
, dbo.PivotedSources.[1993]*PivotedSources_1.[1993] AS [1993]
, dbo.PivotedSources.[1994]*PivotedSources_1.[1994] AS [1994]
, dbo.PivotedSources.[1995]*PivotedSources_1.[1995] AS [1995]
, dbo.PivotedSources.[1996]*PivotedSources_1.[1996] AS [1996]
, dbo.PivotedSources.[1997]*PivotedSources_1.[1997] AS [1997]
, dbo.PivotedSources.[1998]*PivotedSources_1.[1998] AS [1998]
, dbo.PivotedSources.[1999]*PivotedSources_1.[1999] AS [1999]
, dbo.PivotedSources.[2000]*PivotedSources_1.[2000] AS [2000]
, dbo.PivotedSources.[2001]*PivotedSources_1.[2001] AS [2001]
, dbo.PivotedSources.[2002]*PivotedSources_1.[2002] AS [2002]
, dbo.PivotedSources.[2003]*PivotedSources_1.[2003] AS [2003]
, dbo.PivotedSources.[2004]*PivotedSources_1.[2004] AS [2004]
, dbo.PivotedSources.[2005]*PivotedSources_1.[2005] AS [2005]
, dbo.PivotedSources.[2006]*PivotedSources_1.[2006] AS [2006]
, dbo.PivotedSources.[2007]*PivotedSources_1.[2007] AS [2007]
, dbo.PivotedSources.[2008]*PivotedSources_1.[2008] AS [2008]
, dbo.PivotedSources.[2009]*PivotedSources_1.[2009] AS [2009]
, dbo.PivotedSources.[2010]*PivotedSources_1.[2010] AS [2010]
, dbo.PivotedSources.[2011]*PivotedSources_1.[2011] AS [2011]
, dbo.PivotedSources.[2012]*PivotedSources_1.[2012] AS [2012]
, dbo.PivotedSources.[2013]*PivotedSources_1.[2013] AS [2013]
, dbo.PivotedSources.[2014]*PivotedSources_1.[2014] AS [2014]
, dbo.PivotedSources.[2015]*PivotedSources_1.[2015] AS [2015]
, dbo.PivotedSources.[2016]*PivotedSources_1.[2016] AS [2016]
, dbo.PivotedSources.[2017]*PivotedSources_1.[2017] AS [2017]
FROM dbo.PivotedSources LEFT OUTER JOIN
 dbo.PivotedSources AS PivotedSources_1 ON 
 dbo.PivotedSources.SourceName = PivotedSources_1.SourceName AND 
 dbo.PivotedSources.DefinitionName = PivotedSources_1.DefinitionName AND 
 dbo.PivotedSources.GeoSourceName = PivotedSources_1.GeoSourceName
WHERE
(dbo.PivotedSources.SourceName = N'IFS2018') AND 
(dbo.PivotedSources.IndicatorSourceCode = N'NGDP_SA_XDC') AND 
(PivotedSources_1.IndicatorSourceCode = N'EDNA_USD_XDC_RATE')
GO



Insert into dbo.PivotedSources

(
 SourceName, 
 DefinitionName, 
 GeoSourceName, 
 IndicatorSourceName,
 IndicatorSourceCode, 
 [1946]
,[1947]
,[1948]
,[1949]
,[1950]
,[1951]
,[1952]
,[1953]
,[1954]
,[1955]
,[1956]
,[1957]
,[1958]
,[1959]
,[1960]
,[1961]
,[1962]
,[1963]
,[1964]
,[1965]
,[1966]
,[1967]
,[1968]
,[1969]
,[1970]
,[1971]
,[1972]
,[1973]
,[1974]
,[1975]
,[1976]
,[1977]
,[1978]
,[1979]
,[1980]
,[1981]
,[1982]
,[1983]
,[1984]
,[1985]
,[1986]
,[1987]
,[1988]
,[1989]
,[1990]
,[1991]
,[1992]
,[1993]
,[1994]
,[1995]
,[1996]
,[1997]
,[1998]
,[1999]
,[2000]
,[2001]
,[2002]
,[2003]
,[2004]
,[2005]
,[2006]
,[2007]
,[2008]
,[2009]
,[2010]
,[2011]
,[2012]
,[2013]
,[2014]
,[2015]
,[2016]
,[2017]
)
select 
 SourceName, 
 DefinitionName, 
 GeoSourceName, 
 IndicatorSourceName,
 IndicatorSourceCode, 
 [1946]
,[1947]
,[1948]
,[1949]
,[1950]
,[1951]
,[1952]
,[1953]
,[1954]
,[1955]
,[1956]
,[1957]
,[1958]
,[1959]
,[1960]
,[1961]
,[1962]
,[1963]
,[1964]
,[1965]
,[1966]
,[1967]
,[1968]
,[1969]
,[1970]
,[1971]
,[1972]
,[1973]
,[1974]
,[1975]
,[1976]
,[1977]
,[1978]
,[1979]
,[1980]
,[1981]
,[1982]
,[1983]
,[1984]
,[1985]
,[1986]
,[1987]
,[1988]
,[1989]
,[1990]
,[1991]
,[1992]
,[1993]
,[1994]
,[1995]
,[1996]
,[1997]
,[1998]
,[1999]
,[2000]
,[2001]
,[2002]
,[2003]
,[2004]
,[2005]
,[2006]
,[2007]
,[2008]
,[2009]
,[2010]
,[2011]
,[2012]
,[2013]
,[2014]
,[2015]
,[2016]
,[2017]
 from dbo.pivotedUSD_GDP

Insert into dbo.PivotedSources

(
 SourceName, 
 DefinitionName, 
 GeoSourceName, 
 IndicatorSourceName,
 IndicatorSourceCode, 
 [1946]
,[1947]
,[1948]
,[1949]
,[1950]
,[1951]
,[1952]
,[1953]
,[1954]
,[1955]
,[1956]
,[1957]
,[1958]
,[1959]
,[1960]
,[1961]
,[1962]
,[1963]
,[1964]
,[1965]
,[1966]
,[1967]
,[1968]
,[1969]
,[1970]
,[1971]
,[1972]
,[1973]
,[1974]
,[1975]
,[1976]
,[1977]
,[1978]
,[1979]
,[1980]
,[1981]
,[1982]
,[1983]
,[1984]
,[1985]
,[1986]
,[1987]
,[1988]
,[1989]
,[1990]
,[1991]
,[1992]
,[1993]
,[1994]
,[1995]
,[1996]
,[1997]
,[1998]
,[1999]
,[2000]
,[2001]
,[2002]
,[2003]
,[2004]
,[2005]
,[2006]
,[2007]
,[2008]
,[2009]
,[2010]
,[2011]
,[2012]
,[2013]
,[2014]
,[2015]
,[2016]
,[2017]
)

select 
 SourceName, 
 DefinitionName, 
 GeoSourceName, 
 IndicatorSourceName,
 IndicatorSourceCode, 
 [1946]
,[1947]
,[1948]
,[1949]
,[1950]
,[1951]
,[1952]
,[1953]
,[1954]
,[1955]
,[1956]
,[1957]
,[1958]
,[1959]
,[1960]
,[1961]
,[1962]
,[1963]
,[1964]
,[1965]
,[1966]
,[1967]
,[1968]
,[1969]
,[1970]
,[1971]
,[1972]
,[1973]
,[1974]
,[1975]
,[1976]
,[1977]
,[1978]
,[1979]
,[1980]
,[1981]
,[1982]
,[1983]
,[1984]
,[1985]
,[1986]
,[1987]
,[1988]
,[1989]
,[1990]
,[1991]
,[1992]
,[1993]
,[1994]
,[1995]
,[1996]
,[1997]
,[1998]
,[1999]
,[2000]
,[2001]
,[2002]
,[2003]
,[2004]
,[2005]
,[2006]
,[2007]
,[2008]
,[2009]
,[2010]
,[2011]
,[2012]
,[2013]
,[2014]
,[2015]
,[2016]
,[2017]


from dbo.pivotedUSD_GDP_SA