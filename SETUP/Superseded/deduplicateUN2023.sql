/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [OLTP_FactID]
      ,[SourceName]
      ,[GeoSourceName]
      ,[IndicatorSourceCode]
      ,[Date]
      ,[Value]
  FROM [MACROHISTORY_OLTP_230505].[dbo].[FactSource]
  where SourceName='UN2023-USD-GDP-SECTORS' AND GeoSourceName='USSR (Former)' and year (date)=1990

