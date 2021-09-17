# Macroeconomic History Data Source Notes

11 December2020

These are rough notes on the various data sources, where they came from, and how they are prepared for upload

They relate mainly to new data uploaded in October 2020 and after

## WDI

This is the priority because it is the most current and begins with early dates

The current dataset is pivoted with all series (447,000 rows) 

There is a ‘maximum limit’ on the number of cells that can be downloaded. 

The selection pane is usable and a logged-in user can save it. So data is downloaded in recognizable chunks. 

- Chunk 1: The national accounts data, aggregates only (without GDP per capita and GNI per capita)
- Chunk 2: Balance of Payments (all data)
- Chunk 3: Demographics and Income Distribution (selection)

Meta: ask for scaling to be applied. Ask for NA to be .., because it makes the prep easier

#### Prep

1. Amalgamate the chunks using cut and paste to create WDI2020.xlsx
2. Create a cleaned sheet with both chunks in it
3. Change the first four column names to be Country Name, Country Code, Indicator Name, Indicator Code
4. Remove the scale code
5. Remove the junk from the year headings
6. Export as CSV

## UNITED NATIONS

The UNstats site is comprehensive but sprawling and unbelievably user-unfriendly. Everything is there, but the problem is to find it.

- [ ] The parts that contain the 'backend access' are here: http://data.un.org/, including the 'Data Browser' at https://data.un.org/SdmxBrowser/start. This is complete but time-consuming. It is documented here: http://data.un.org/Host.aspx?Content=API. It supplies access to the official statistics via the SDMX dissemination protocol.
- [ ] The international data exchange site is here:https://unstats.un.org/unsd/nationalaccount/sdmxdata/. Gives quick access to all series from a single coutry
- [ ] The parts that are organised as a modern portal can be found here: https://unstats.un.org/home/. 
  - [ ] This leads for example to https://unstats.un.org/unsd/nationalaccount/default.asp
  - [ ] and to https://unstats.un.org/unsd/snaama/
  - [ ] The 'basic data selection' is here https://unstats.un.org/unsd/snaama/Basic
  - [ ] A 'quick download' section here https://unstats.un.org/unsd/snaama/downloads
  - [ ] This site has its own API here https://unstats.un.org/unsd/amaapi/swagger/index.html which gives the JSON structure for requests
- [ ] The various parts don't have much interconnection so it's easiest to think of them as separate sources for the same data.

At the date of this document, two datasets are obtained from the UN site:

- [ ] The 'official statistics' (UN2020-OFFICIAL) contain data supplied by the national statistics agencies of the countries concerned. It provides the most extensive metadata and is therefore the main source provided by the data laboratory. The 2020 download was obtained via the data browser. Because this quite clunky system imposes download limitations it was obtained in three 'chunks' and then reconsolidated. It went into the file called `UN2020-OFFICIAL.csv`. 
- [ ] The 'quick download' datasets (https://unstats.un.org/unsd/snaama/downloads) giving 
  - [ ] GDP breakdown in 
    - [ ] national currency, 
    - [ ] US dollars, 
    - [ ] constant 2015 LCU, 
    - [ ] constant 2015 USD
  - [ ] GNI in LCU

## WEO

The World Economic Outlook series is produced twice a year in April and October.

- [ ] It includes forecasts for about 5 years ahead
- [ ] The data only starts in 1980
  - [ ] However in 2002 the data series started in 1970 and so is included for completeness
  - [ ] The two series have not been spliced, though it would be an idea

There are 46 indicators, though some are repeats in different units (local currency, USD, Share, Growth, etc)

- [ ] We only upload a selection of indicators, essentially to exclude those that can be simply calculated from the supplied data
- [ ] But we generally include LCU, USD, and PPP measures
- [ ] We create a composite indicator at ETL which combines the indicator and its units; this seems redundant so in the 2020 pass we'll try to eliminate it
- [ ] A selection of indicators is then made via the dimIndicator table
- [ ] If an indicator isn't in the dimIndicator table, it doesn't get passed through to the ROLAP database (and hence doesn't appear on the Analysis Server), but it is accessible in the OLTP database, though only in the FactSource table, not in the FactQuery view

## General notes



# Series Notes

Isolated remarks on issues arising with particular providers and series

Duplication

·    WDI and WEO record components (eg Czech Republic, Slovakia) and do not supply aggregates (eg Czechoslovakia, USSR, Yugoslavia, Ethiopia), BUT before a country divides, they sometimes record the aggregate as if it were the part (so Czechoslovakia, prior to 2010, is presented as ‘Czech Republic’ as if the Czech Republic was the entire thing, until the split.

·    UN GDP figures record data for ‘Former’ entities which are duplicated in the year of transition, for all GDP *measures* and *components* unless measured on constant LCU. These are:

| LCU-CURRENT.1  |
| -------------- |
| LCU-CURRENT.2  |
| LCU-CURRENT.3  |
| LCU-CURRENT.4  |
| LCU-CURRENT.5  |
| LCU-CURRENT.9  |
| USD-CONSTANT.1 |
| USD-CONSTANT.2 |
| USD-CONSTANT.3 |
| USD-CONSTANT.4 |
| USD-CONSTANT.5 |
| USD-CONSTANT.9 |
| USD-CURRENT.1  |
| USD-CURRENT.2  |
| USD-CURRENT.3  |
| USD-CURRENT.4  |
| USD-CURRENT.5  |
| USD-CURRENT.9  |

·    For constant LCU, only former Former Netherlands Antilles and former Sudan are duplicated

·    

·    UN Population records only for aggregates – but is reasonably complete

·    UN Official figures ditto

Missing data

·    WDI clearly just records what it is able to so there are breaks, including mid-series. Hence aggregates have to be checked, unless (presumably) calculated by World Bank itself and supplied as such.

·    WDI Coverage does go back to 1960 for a substantial selection of countries

·    WEO just goes back to 1980

·    WEO2002 went back to 1970

Dollar Series

·    WDI has USD series wherever it has LCU

·    WEO has USD series

·    UN has dollar series (need to be coded carefully)

Series Counts

​       WDI about 400,000

​       WEO about 90,000

UN2018 776,000

Scaling Issues

​       WEO population needs to scale as follows:

NGDP_R       Billions Gross domestic product, constant prices

NGDP         Billions Gross domestic product, current prices

NGDPD        Billions Gross domestic product, current prices

PPPGDP       Billions Gross domestic product, current prices

GGR          Billions General government revenue

GGX          Billions General government total expenditure

GGXCNL       Billions General government net lending/borrowing

GGSB         Billions General government structural balance

GGXONLB      Billions General government primary net lending/borrowing

GGXWDN      Billions General government net debt

GGXWDG      Billions General government gross debt

NGDP_FY      Billions Gross domestic product corresponding to fiscal year, current prices

BCA          Billions Current account balance

LE            Millions  Employment

LP            Millions  Population