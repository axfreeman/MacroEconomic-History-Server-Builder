USE [MACROHISTORY_OLTP_230505]
GO

DROP TABLE IF EXISTS [MACROHISTORY_ROLAP_230505].[dbo].[Fact]
Select DimSourceID, 
GeoStandardisedID AS DimGeoStandardisedID,
StandardisedID AS [DimIndicatorStandardisedID],
Year,
Value
INTO [MACROHISTORY_ROLAP_230505].[dbo].[Fact]
FROM FactSourceCompleteView