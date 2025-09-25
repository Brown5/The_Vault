USE [RMABIStaging]
GO

declare @reportname as varchar(100)
set @reportname = 'Class4and13MonthEnd'
;

WITH RPTS AS (
                     SELECT  TblName
							,[Report Name]
							,[columnName]
							,[columnName1]
							--,[column_id]
						FROM
							 (
								SELECT rt.[Report Name]
									  ,md.[Current Database]+'.'+md.[Schema Name]+'.'+md.[tableName] TblName
									  ,md.[columnName]
									  ,CASE WHEN md.[columnName] = rt.ColumnName THEN rt.ColumnName ELSE NULL END AS [columnName1]
									  ------,rt.ColumnName
									  ,md.[column_id]
								  FROM [RMABIStaging].[dbo].[MetaData] md
									   LEFT JOIN [RMABIStaging].[dbo].[BayBridgeReportsTables] rt
									ON (md.[Current Database]+'.'+md.[Schema Name]+'.'+md.[tableName]) = RTRIM(LTRIM(REPLACE(REPLACE(rt.[Tables],'[',''),']','')))
								   --AND md.[columnName] = rt.ColumnName 
								 --WHERE md.[tableName]  IS NOT NULL 
								 --WHERE rt.[Report Name] = 'Archived Documents Report'
							 ) a
					   --WHERE [Report Name] IS NOT NULL
					   WHERE [columnName1] IS NOT NULL
						 --AND TblName LIKE '%Pension%'
					--ORDER BY TblName--,--COUNT(distinct [Report Name])--,,TblName,[column_id]
              )

  SELECT distinct rt.[Report Name]
        ,rt.TblName
	    ,rt.[columnName]
	    ,rt.[columnName1]
        ,st.[SrcDB]
        ,st.[SrcSchema]
        ,st.[SRCtableName]
        ,st.[SrcColumnName]
        ,st.[SrcColumnID]
        ,st.[SrcDataType]
        ,st.[PrimaryKey]
        ,st.[Database]
        ,st.[Schema Name]
        ,st.[tableName]
        ,st.[columnName]
        ,st.[column_id]
        ,st.[DataType]
        ,st.[MaxLength]
        ,st.[ProcSchemaName]
        ,st.[objectName]
        ,st.[ProcSchemaName1]
        ,st.[TrSchemaName]
        ,st.[trtableName]
        ,st.[trcolumnName]
        ,st.[trcolumn_id]
        ,st.[TrDataType]
        ,st.[trMaxLength]
        ,st.[trPrimaryKey]
        ,st.[trobjectName]
        ,st.[trProcSchemaName1]
        ,st.[trobjectName1]
        ,st.[trobjectType1]
        ,st.[maSchemaName]
        ,st.[matableName]
        ,st.[macolumnName]
        ,st.[macolumn_id]
        ,st.[maDataType]
        ,st.[maMaxLength]
        ,st.[maPrimaryKey]
        ,st.[maProcSchemaName]
        ,st.[maobjectName]
        ,st.[maProcSchemaName1]
        ,st.[maobjectName1]
        ,st.[maobjectType1]
    FROM RPTS rt
         JOIN [dbo].[Src2Target] st
      ON rt.TblName = (st.[SrcDB]+'.'+st.[SrcSchema]+'.'+st.[SRCtableName])
     AND rt.[columnName] = st.[SrcColumnName]
   WHERE rt.[Report Name] = @reportname 
ORDER BY rt.[Report Name]
        --,rt.TblName
	    --,rt.[columnName]
