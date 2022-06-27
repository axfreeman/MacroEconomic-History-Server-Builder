-- script to clean up macrohistory_rolap  after finishing ROLAP transfer
Use macrohistory_oltp_220522
DROP TABLE IF EXISTS MADDISON_TD_File;
DROP TABLE IF EXISTS UN_TD_File;
DROP TABLE IF EXISTS WID_TD_File;
DROP TABLE IF EXISTS Temp_IFS_USD_SA_Table
DROP TABLE IF EXISTS Temp_IFS_USD_Table
DROP TABLE IF EXISTS Temp_PENN_USD_Table
DROP TABLE IF EXISTS UN_duplicates
DROP VIEW IF EXISTS DuplicateFinder
GO
Use macrohistory_rolap
-- Many of these no longer relevant  26/09/2020
DROP VIEW IF EXISTS AddedDefinitions;
DROP VIEW IF EXISTS Barro_Ursua_cleaner;
DROP VIEW IF EXISTS Barro_Ursua_Indexed_gdp;
DROP VIEW IF EXISTS BARRO_URSUA_WDI2018_Deindexed;
DROP VIEW IF EXISTS IFSSeasonalAdjustmentRemoval;
DROP VIEW IF EXISTS IFSSeasonalAdjustmentRemoval_KeyFinder;
DROP VIEW IF EXISTS Macrohist_cleaner;
DROP VIEW IF EXISTS Macrohist_Indexed_rgdppc;
DROP VIEW IF EXISTS Macrohist_WDI2018_Deindexed;
DROP VIEW IF EXISTS Maddison_Population;
DROP VIEW IF EXISTS MADDISON_RU_Corrector;
DROP VIEW IF EXISTS MADDISON_RU_Corrector_KeyFinder;
DROP VIEW IF EXISTS NormalisedAddedDefinitions;
DROP VIEW IF EXISTS PENN_ExchangeRates;
DROP VIEW IF EXISTS UN_RU_Corrector;
DROP VIEW IF EXISTS UN_RU_Corrector_KeyFinder;
DROP VIEW IF EXISTS WDI2018_2005_REALGDP_BASE;
DROP VIEW IF EXISTS WDI2018_2006_REALGDP_BASE;
DROP VIEW IF EXISTS WID_Foreign_Income_USD_Calculated;
DROP VIEW IF EXISTS WID_Foreign_Income_USD_Calculated_KeyFinder;
DROP VIEW IF EXISTS WID_National_Income;
DROP VIEW IF EXISTS WID_National_Income_Calculated;
DROP VIEW IF EXISTS WID_National_Income_Calculated_KeyFinder;
DROP VIEW IF EXISTS WID_National_Income_USD_Calculated;
DROP VIEW IF EXISTS WID_National_Income_USD_Calculated_KeyFinder;
DROP VIEW IF EXISTS WID_NDP_USD_Calculated;
DROP VIEW IF EXISTS WID_RU_Corrector;
DROP VIEW IF EXISTS WID_RU_Corrector_KeyFinder;
DROP VIEW IF EXISTS WID_USD_Calculated_KeyFinder;
DROP VIEW IF EXISTS PENN_USD_Calculated_KeyFinder;
DROP VIEW IF EXISTS PENN_USD_TemporaryTable;
