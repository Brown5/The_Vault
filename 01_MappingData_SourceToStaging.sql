-- Updated Staging Tables query showing the stored procedures used
-- and the tables in Staging (Target).

-- The source tables for Staging are not in the data warehouse.
-- As a result, data is required from the metadata tables in the RMABIStaging database

Use RMADW;
GO


drop table /*if exists*/ #StagingTBLs

SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey' 
INTO #StagingTBLs
FROM sys.tables t
	JOIN sys.columns c ON c.object_id = t.object_id
	JOIN sys.schemas st ON st.schema_id = t.schema_id AND st.schema_id = 5
    JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	LEFT JOIN (sys.sql_dependencies d
	JOIN sys.objects o ON d.object_id = o.object_id AND o.type = 'P'
	JOIN sys.schemas s ON o.schema_id = s.schema_id AND o.schema_id = 5) ON d.referenced_major_id = t.object_id AND d.referenced_minor_id = c.column_id AND t.schema_id = 5
	--ORDER BY tableName, column_id
--WHERE t.name NOT LIKE '%Audit'


--DROP TABLE #StagingTables0
--DROP TABLE #StagingTables1
--SELECT DISTINCT tableName
--INTO #StagingTables0
--FROM (
--SELECT DISTINCT
--	--'1' AS Query,
--	st.ProcSchemaName
--	,st.ProcName
--	--,st.objectName
--    ,DB_NAME() AS [Database]
--	--,st.[Schema Name]
--    ,st.tableSchema --.[Schema Name]
--    ,st.tableName
--	,st.columnName
--	,st.column_id
--    ,st.DataType
--    ,st.Max_Length
--	,st.is_nullable
--	,md.[Current Database] SrcDB
--    ,md.[Schema Name] SrcSchema
--    ,md.[tableName] [SRCtableName]
--    ,md.[columnName] SrcColumnName
--    ,md.[column_id] SrcColumnID
--    ,md.[DataType] SrcDataType
--	,md.is_nullable SrcNullable
--	--,st.[ProcSchemaName1]
--	--,st.objectName1
--	--,st.objectType1
--	,(SELECT CAST(MAX(CAST(PrimaryKey AS int)) as bit) FROM [RMABIStaging].[dbo].[MetaData] md1 
--	WHERE md1.column_id = md.column_id AND md1.tableName = md.tableName AND md1.[Schema Name] = md.[Schema Name]) PrimaryKey --   md.PrimaryKey
----SELECT DISTINCT md.tablename
--FROM [RMABIStaging].[dbo].[MetaData] md
--JOIN #StagingTBLs st
-- 		  on (Case WHEN CHARINDEX('_', md.[Schema Name] + md.tableName) > 0 THEN REPLACE(md.[Schema Name] + md.tableName, '_', '') END = st.tableName OR
--			  CASE WHEN CHARINDEX('_', md.tableName) > 0 THEN REPLACE(md.[tableName],'_','') END = st.tableName OR
--			  REPLACE(md.[Schema Name] + md.tableName,'RMA','') = st.tableName OR
--			  md.[Schema Name] + md.tableName = st.tableName OR
--			  CASE WHEN md.[Schema Name] + md.tableName = 'MedicalService' THEN 'MedicalServiceType' END = st.tableName OR
--			  CASE WHEN md.[Schema Name] + md.tableName = 'MedicalMedicalItemType' THEN 'MedicalItemType' END = st.tableName
--				--md.tableName = st.tableName
--				) and md.columnName = st.columnName
--    WHERE st.tableName is not null
--	--AND st.tableName NOT LIKE '%Audit'
--	AND md.[Current Database] = 'RMAProd'
--	AND st.tableName NOT LIKE '%fnGet%' -- Function call
--	AND st.tableName NOT IN ('AgentAllocation', -- Finance Collections in arrears
--						  'FileAccountsAllocated', -- Finance Collections in arrears
--						  'FinanceBankResponseFiles', -- Banking Response File import
--						  'WhatsAppDeclaration', -- WhatsApp data
--						  'CompensationMedicalInvoiceAuditCareType', -- Derived specifically for staging - not in PROD
--						  'CompensationMedicalInvoiceCareType', -- Derived specifically for staging - not in PROD
--						  'MedicalBenefitsContactMailItem', -- Email from EmailExtractor
--						  'PensionPensionLedgerDeleted' -- Derived to manage deleted pension ledger records
--						  )
--) SRC


--SELECT DISTINCT st.tableName, st1.tableName
--FROM #StagingTables1 st1
--FULL JOIN #StagingTables0 st ON st1.tableName = st.tableName
----WHERE st1.tableName NOT LIKE '%Audit'
--WHERE st.tableName is not null AND st1.tableName IS NULL

-- Original as used in Transformation, Mart and Derived
--SELECT /*TGT.object_id, */TGT.ProcSchemaName, TGT.ProcName, TGT.tableSchema, TGT.tableName, TGT.columnName, TGT.column_id, TGT.datatype, TGT.max_length, TGT.is_nullable, TGT.PrimaryKey,
--		NULL AS sourceDB, SRC.tableSchema sourceSchema, SRC.tableName sourceTable, SRC.columnName sourceColumn, SRC.column_id source_id, SRC.datatype sourceType, SRC.max_length source_length, SRC.is_nullable source_is_nullable, SRC.PrimaryKey source_PrimaryKey
--INTO #StagingTBLs
--FROM
--(
--SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
--FROM sys.sql_dependencies d
--	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (5) AND o.[type] = 'P' --(1,5,6,7,8)
--         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
--	     JOIN sys.tables t  ON c.object_id = t.object_id and t.schema_id = 5
--		 JOIN sys.schemas s ON s.schema_id = o.schema_id
--		 JOIN sys.schemas st ON st.schema_id = t.schema_id
--         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
--         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
--WHERE t.name NOT LIKE '%Audit'
--AND 'prc' + t.name = o.name
----ORDER BY ProcName, tableName, column_id
--) TGT
--LEFT JOIN
--(
--SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
--FROM sys.sql_dependencies d
--	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (5) AND o.[type] = 'P' --(1,5,6,7,8)
--         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
--	     JOIN sys.tables t  ON c.object_id = t.object_id and t.schema_id != 5
--		 JOIN sys.schemas s ON s.schema_id = o.schema_id
--		 JOIN sys.schemas st ON st.schema_id = t.schema_id
--         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
--         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
--WHERE t.name NOT LIKE '%Audit'
----ORDER BY ProcName, tableName, column_id
--) SRC
--ON TGT.object_id = SRC.object_id AND TGT.columnName = SRC.columnName --AND TGT.tableSchema != SRC.tableSchema  --AND TGT.tableName != SRC.tableName --AND REPLACE(TGT.tableName,'Dim','') LIKE '%' + SRC.tableName + '%' --AND ((TGT.max_length >= SRC.max_length AND TGT.datatype = SRC.datatype) OR TGT.datatype LIKE '%' + SRC.datatype) --AND TGT.max_length >= SRC.max_length-- 
--ORDER BY TGT.ProcName, TGT.tableName, TGT.column_id


--SELECT * FROM #StagingTBLs
--ORDER BY ProcName, tableName, column_id

--SELECT DISTINCT tableName FROM (
--SELECT NULL '1', NULL '2', NULL '3', st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
--FROM  sys.columns c
--	     JOIN sys.tables t  ON c.object_id = t.object_id and t.schema_id = 5
--		 JOIN sys.schemas st ON st.schema_id = t.schema_id
--         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
--         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
--WHERE t.name NOT LIKE '%Audit'
--) SRC
--AND 'prc' + t.name = o.name
--ORDER BY ProcName, tableName, column_id


--SELECT DISTINCT t.name, o.name
--FROM sys.tables t
--Left JOIN sys.sql_dependencies d ON t.object_id = d.referenced_major_id AND t.schema_id = 5 --AND 
--LEFT JOIN sys.objects o ON d.object_id = o.object_id AND o.[type] = 'P' and o.schema_id = 5-- AND o.name LIKE 'prc%'


--SELECT DISTINCT tableName FROM #StagingTBLs
--ORDER BY tablename --ProcName, tableName, column_id


-- Original Query to get the staging table names and the procedures using them
-- This query shows tables not just populated by Staging procedures, but read by Transformation procedures
-- The source fields are not shown - they only come up when joined with the metadata tables
--drop table /*if exists*/ #StagingTBLs1
--  SELECT distinct ssch.[name] as [Schema Name]
--        ,t.name AS tableName
--		,c.name AS columnName
--		,c.column_id
--        ,ty.Name 'DataType'
--        ,c.max_length 'MaxLength'
--        ,c.is_nullable
--        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
--		,max(sscho.[name]) as [ProcSchemaName]
--		,max(o.name) AS objectName
--		,max(sscho1.[name]) as [ProcSchemaName1]
--		,max(o1.name) AS objectName1
--		,max(o1.type_desc) AS objectType1
--    INTO #StagingTBLs1
--    FROM sys.sql_dependencies d
--         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
--	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
--	     LEFT JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (1,5,7,8)
--	     LEFT JOIN sys.objects oo ON d.object_id = oo.object_id and o.schema_id in (1,5,7,8)
--	     LEFT JOIN sys.objects o1 ON d.object_id = o1.object_id and o1.schema_id in (1,6,7,8)
--		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
--		 LEFT JOIN sys.schemas sscho ON oo.schema_id = sscho.schema_id and o.schema_id in (5)
--		 LEFT JOIN sys.schemas sscho1 ON o1.schema_id = sscho1.schema_id and o1.schema_id in (6)
--         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
--         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
--   WHERE ssch.[name] = 'Staging'
--    --AND t.name = 'CompensationClaimEstimate'
--group by ssch.[name]
--        ,t.name 
--		,c.name 
--		,c.column_id
--        ,ty.Name 
--        ,c.max_length 
--        ,c.is_nullable
--        ,ISNULL(i.is_primary_key, 0)
--ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id


--SELECT DISTINCT tableName FROM #StagingTBLs1
--WHERE ProcSchemaName IS NULL AND [ProcSchemaName1] IS NULL

--SELECT DISTINCT tablename FROM #StagingTBLs1

--SELECT DISTINCT st.tableName, st1.tableName
--FROM #StagingTBLs1 st1
--FULL JOIN #StagingTBLs st ON st1.tableName = st.tableName
--WHERE st1.tableName NOT LIKE '%Audit'

--SELECT * FROM [RMABIStaging].[dbo].[MetaData]

drop table /*if exists*/ #Base

   SELECT 
		  sg.[ProcSchemaName]
		 ,sg.ProcName
         ,sg.[Database]
         ,sg.tableSchema --[Schema Name]
         ,sg.tableName
		 ,sg.columnName
		 ,sg.column_id
         ,sg.DataType
         ,sg.Max_Length
		 ,sg.is_nullable
		 ,sg.SrcDB
         ,sg.SrcSchema
         ,sg.[SRCtableName]
         ,sg.SrcColumnName
         ,sg.SrcColumnID
         ,sg.SrcDataType
		 ,sg.SrcMaxLength
		 ,sg.SrcNullable
		 --,sg.[ProcSchemaName1]
		 --,sg.objectName1
		 --,sg.objectType1   
		 ,sg.PrimaryKey-- MAX(CONVERT(TINYINT,sg.PrimaryKey)) AS PrimaryKey
     INTO #Base
     FROM
	      (
-- Initial query: RMAProd - all tables (313)
--SELECT Distinct tableName--, SrcSchema + SRCtableName FROM (
--INTO #StagingTables1
--FROM (
   SELECT DISTINCT
			--'1' AS Query,
		  st.ProcSchemaName
		 ,st.ProcName
		 --,st.objectName
         ,DB_NAME() AS [Database]
		 --,st.[Schema Name]
         ,st.tableSchema --.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName] SrcColumnName
         ,md.[column_id] SrcColumnID
         ,md.[DataType] SrcDataType
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		 ,(SELECT CAST(MAX(CAST(PrimaryKey AS int)) as bit) FROM [RMABIStaging].[dbo].[MetaData] md1 
			WHERE md1.column_id = md.column_id AND md1.tableName = md.tableName AND md1.[Schema Name] = md.[Schema Name]) PrimaryKey --   md.PrimaryKey
	 --SELECT DISTINCT md.tablename
     FROM [RMABIStaging].[dbo].[MetaData] md
	 --WHERE md.[Current Database] = 'RMAProd'
	      left join #StagingTBLs st 
     --FROM #StagingTBLs st 
	    --  Left join [RMABIStaging].[dbo].[MetaData] md
		  on (Case WHEN CHARINDEX('_', md.[Schema Name] + md.tableName) > 0 THEN REPLACE(md.[Schema Name] + md.tableName, '_', '') END = st.tableName OR
			  CASE WHEN CHARINDEX('_', md.tableName) > 0 THEN REPLACE(md.[tableName],'_','') END = st.tableName OR
			  REPLACE(md.[Schema Name] + md.tableName,'RMA','') = st.tableName OR
			  md.[Schema Name] + md.tableName = st.tableName OR
			  CASE WHEN md.[Schema Name] + md.tableName = 'MedicalService' THEN 'MedicalServiceType' END = st.tableName OR
			  CASE WHEN md.[Schema Name] + md.tableName = 'MedicalMedicalItemType' THEN 'MedicalItemType' END = st.tableName
				--md.tableName = st.tableName
				) and md.columnName = st.columnName
    WHERE st.tableName is not null
	--AND st.tableName NOT LIKE '%Audit'
	AND md.[Current Database] = 'RMAProd'
	AND st.tableName NOT LIKE '%fnGet%' -- Function call
	AND st.tableName NOT IN ('AgentAllocation', -- Finance Collections in arrears
						  'FileAccountsAllocated', -- Finance Collections in arrears
						  'FinanceBankResponseFiles', -- Banking Response File import
						  'WhatsAppDeclaration', -- WhatsApp data
						  'CompensationMedicalInvoiceAuditCareType', -- Derived specifically for staging - not in PROD
						  'CompensationMedicalInvoiceCareType', -- Derived specifically for staging - not in PROD
						  'MedicalBenefitsContactMailItem', -- Email from EmailExtractor
						  'PensionPensionLedgerDeleted' -- Derived to manage deleted pension ledger records
						  )
					--) SRC
					--ORDER BY tableName
	--AND md.PrimaryKey = 0
	--ORDER BY SrcSchema, SrcTableName, SrcColumnID
	--ORDER BY st.tableName
	 -- and  md.[Schema Name] ='Compensation'
		--and  md.[tableName] in ('ClaimEstimate')


/* ******************************************
-- Testing to find all the RMAProd tables in staging
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'Accounts%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'Imaging%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'MDM%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'RMABIStaging%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'APIM%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'BHF%'
SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName LIKE 'FACS%'


SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
WHERE tableName NOT LIKE 'Account%'
AND tableName NOT LIKE 'Imaging%'
AND tableName NOT LIKE 'MDM%'
AND tableName NOT LIKE 'RMABIStaging%'
AND tableName NOT LIKE 'APIM%'
AND tableName NOT LIKE '%BHF%'
AND tableName NOT LIKE 'FACS%'
AND tableName NOT LIKE 'ExternalNIHL%'
AND tableName NOT LIKE '%fnGet%' -- Function call
AND tableName NOT IN ('AgentAllocation', -- Finance Collections in arrears
					  'FileAccountsAllocated', -- Finance Collections in arrears
					  'FinanceBankResponseFiles', -- Banking Response File import
					  'WhatsAppDeclaration', -- WhatsApp data
					  'CompensationMedicalInvoiceAuditCareType', -- Derived specifically for staging - not in PROD
					  'CompensationMedicalInvoiceCareType', -- Derived specifically for staging - not in PROD
					  'MedicalBenefitsContactMailItem', -- Email from EmailExtractor
					  'PensionPensionLedgerDeleted' -- Derived to manage deleted pension ledger records
					  )
AND tableName NOT IN (
	SELECT DISTINCT tableName FROM (
SELECT DISTINCT
		  md.[Current Database] SrcDB
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st 
		  on (Case WHEN CHARINDEX('_', md.[Schema Name] + md.tableName) > 0 THEN REPLACE(md.[Schema Name] + md.tableName, '_', '') END = st.tableName OR
			  CASE WHEN CHARINDEX('_', md.tableName) > 0 THEN REPLACE(md.[tableName],'_','') END = st.tableName OR
			  REPLACE(md.[Schema Name] + md.tableName,'RMA','') = st.tableName OR
			  md.[Schema Name] + md.tableName = st.tableName OR
			  CASE WHEN md.[Schema Name] + md.tableName = 'MedicalService' THEN 'MedicalServiceType' END = st.tableName --OR
				--md.tableName = st.tableName
				) and md.columnName = st.columnName
    WHERE st.tableName is not null
	AND md.[Current Database] = 'RMAProd'
	--AND md.PrimaryKey = 0
	--ORDER BY SrcSchema, SrcTableName--, SrcColumnID
	) SRC
)

	--SELECT * FROM RMADW.Staging.MedicalServiceType
********************* */	


  UNION ALL

 -- SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
	--WHERE tableName LIKE 'Accounts%'
	--AND TableName NOT IN (
	--SELECT tableName FROM (
-- Second query: Accounts only (48 tables)
  SELECT DISTINCT	--'2' AS Query,
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB--, (md.[Schema Name]+REPLACE(md.[tableName],'_',''))
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id] SrcColumnID
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		,(SELECT CAST(MAX(CAST(PrimaryKey AS int)) as bit) FROM [RMABIStaging].[dbo].[MetaData] md1 
			WHERE md1.column_id = md.column_id AND md1.tableName = md.tableName AND md1.[Schema Name] = md.[Schema Name]) PrimaryKey --   md.PrimaryKey
		 --,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	       left join #StagingTBLs st on (
			md.[Current Database]+REPLACE(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','document'),'tran','transaction'),'param','parameter') = st.tableName OR
			CASE WHEN md.[Current Database]+REPLACE(md.[tableName],'_','') = 'AccountsGLParam' THEN 'AccountsGLParam' END = st.tableName
			)
		    and md.columnName = st.columnName
	where st.[tableName] is not null
	AND md.[Current Database] = 'Accounts'
	AND st.TableName NOT IN (
							 'AccountsBankStatementTransaction' -- Generated in StoredProc
							 )
	--ORDER BY SrcSchema, SrcTableName, SrcColumnID
--	) SRC
--)
/*
SELECT * FROM [RMABIStaging].[dbo].[MetaData] md
WHERE md.tableName LIKE '%bank%tran%' AND md.[Current Database] = 'Accounts'
*/
		   --    WHERE md.[Current Database] = 'RMAProd'
				 -- and  md.[Schema Name] ='Compensation'
					--and  md.[tableName] in ('ClaimEstimate')
		--AND md.[Current Database] = 'RMAProd'
	 -- AND  md.[Schema Name] ='Compensation'
		--AND  md.[tableName] in ('ClaimEstimate')

  UNION ALL

 -- SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
	--WHERE tableName LIKE 'Imaging%'
	--AND tableName NOT IN (
	--SELECT tableName FROM (
-- Third query: Imaging only (20 tables?)
  SELECT DISTINCT	--'3' AS Query,
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB--, (md.[Schema Name]+REPLACE(md.[tableName],'_',''))
         ,md.[Schema Name] SRCSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id] SrcColumnID
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		,(SELECT CAST(MAX(CAST(PrimaryKey AS int)) as bit) FROM [RMABIStaging].[dbo].[MetaData] md1 
			WHERE md1.column_id = md.column_id AND md1.tableName = md.tableName AND md1.[Schema Name] = md.[Schema Name]) PrimaryKey --   md.PrimaryKey
		 --,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st on (
		  --(md.[Current Database] +REPLACE(md.[tableName],'_','')) = st.tableName OR
		  (md.[Current Database]+md.[Schema Name]+REPLACE(md.[tableName],'_','')) = st.tableName OR
		  CASE WHEN md.[Current Database]+REPLACE(md.[tableName],'_','') = 'ImagingPensionsImage' THEN 'ImagingPensionsImage' END = st.tableName
		  )
		  and md.columnName = st.columnName
    where st.tableName is not null 
	AND md.[Current Database] = 'Imaging'
	--ORDER BY SrcSchema, SrcTableName, SrcColumnID

--	) SRC
--)
	--AND md.[Current Database] = 'RMAProd'
	--  and  md.[Schema Name] ='Compensation'
	--	and  md.[tableName] in ('ClaimEstimate')
 

  UNION ALL
-----17633

--SELECT DISTINCT [Schema Name], tableName FROM #StagingTBLs
--WHERE tableName LIKE 'MDM%'
--AND TableName NOT IN (
--SELECT tableName FROM (
-- Fourth query: MDS only (15 tables?)
   SELECT DISTINCT
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB--, (md.[Current Database]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id] SrcColumnID
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	       join #StagingTBLs st on md.columnName = st.columnName and 
		   (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'Claims','Claim'))) = st.tableName
     where md.[Current Database] = 'MDS' 
	 AND st.tablename IS NOT NULL
	 	--ORDER BY SrcSchema, SrcTableName, SrcColumnID

--	 ) SRC
--)
	  --and md.tableName = 'cb_doc_header' 
  
  UNION ALL
-- Fifth query: RMABIStaging only (1 table)
   SELECT 
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB--, (md.[Current Database]+md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      join #StagingTBLs st on md.columnName = st.columnName and (md.[Current Database]+md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))= st.tableName
    where md.[Current Database] = 'RMABIStaging' 

  UNION ALL

-- Other queries still to be done:

-- Sixth query: BHF only (7 Tables)
   SELECT DISTINCT 
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
	     ,md.[Current Database] SrcDB
   --      , (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
		 --, (md.[Schema Name]+(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'),'claims','claim')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData_BHF_APIM] md
	      left join #StagingTBLs st 
	   on (md.[Current Database]+(REPLACE(REPLACE(md.[tableName],'_',''),'banks','bank'))) =  RTRIM(LTRIM(st.tableName)) 
	  and md.columnName = st.columnName  
	  --AND md.Datatype != 'sysname'
    where md.[Current Database] = 'BHF'

	--SELECT * FROM [RMABIStaging].[dbo].[MetaData_BHF_APIM]
	--WHERE Datatype = 'sysname'
	--DELETE FROM [RMABIStaging].[dbo].[MetaData_BHF_APIM]
	--WHERE Datatype = 'sysname'

--INSERT INTO RMABIStaging.dbo.metadata_bhf_APIM
--([Current Database], [Schema Name],[tableName],[columnName],[column_id],[DataType],[MaxLength],[is_nullable],[PrimaryKey],[type],[type_desc])
--	SELECT 'BHF' [CurrentDatabase], sc.name schemaName, tb.name tableName, c.name columnName, c.column_id, t.name DataType, c.max_length, c.is_nullable,
--			ISNULL((SELECT is_primary_key FROM sys.indexes i JOIN sys.index_columns ic ON i.object_id = ic.object_id WHERE i.type  =1 AND ic.index_id = 1 and ic.column_id = c.column_id AND i.object_id = c.object_id), 0) PrimaryKey,
--			NULL, NULL 
--	--FROM sys.databases db 
--	FROM sys.schemas sc
--	JOIN sys.tables tb ON sc.schema_id = tb.schema_id
--	JOIN sys.columns c ON tb.object_id = c.object_id
--	JOIN sys.types t ON c.system_type_id = t.system_type_id
--	--ORDER BY object_id
--	WHERE db.name = 'BHF'

    UNION ALL

-- Seventh Query: APIM Database (AZP-INT-API-01) (15 Tables)
    SELECT DISTINCT 
		  st.[ProcSchemaName]
		 ,st.ProcName  --objectName
         ,DB_NAME() AS [Database]
         ,st.tableSchema --[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.Max_Length
		 ,st.is_nullable
		 ,md.[Current Database] SrcDB
   --      , (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
		 --, (md.[Schema Name]+(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'),'claims','claim')))
         ,md.[Schema Name] SRcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id] srcColumnID
         ,md.[DataType]
		 ,md.MaxLength SrcMaxLength
		 ,md.is_nullable SrcNullable
		 --,st.[ProcSchemaName1]
		 --,st.objectName1
		 --,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData_BHF_APIM] md
	      left join #StagingTBLs st 
	   on (
		  md.[Current Database]+md.[Schema Name]+md.[tableName] =  RTRIM(LTRIM(st.tableName)) OR
		  REPLACE(md.[tableName],'TransactionTypeAccounts','BankAccount') =  RTRIM(LTRIM(st.tableName)) OR
		  md.[tableName] =  RTRIM(LTRIM(st.tableName))
	   )
	  and md.columnName = st.columnName  
    where md.[Current Database] = 'APIM'
	AND st.tableName is not null
	--ORDER BY SRcSchema, [SRCtableName], srcColumnID

	--SELECT * FROM #StagingTBLs
	--WHERE tableName = 'WhatsAppDeclaration'
	--ORDER BY column_id


	      ) sg
--group by  sg.SrcDB
--         ,sg.SrcSchema
--         ,sg.[SRCtableName]
--         ,sg.SrcColumnName
--         ,sg.SrcColumnID
--         ,sg.SrcDataType
--         ,sg.[Database]
--         ,sg.[Schema Name]
--         ,sg.tableName
--		 ,sg.columnName
--		 ,sg.column_id
--         ,sg.DataType
--         ,sg.MaxLength
--		 ,sg.[ProcSchemaName]
--		 ,sg.objectName
--		 ,sg.[ProcSchemaName1]
--		 ,sg.objectName1
--		 ,sg.objectType1   

SELECT * FROM #Base
ORDER BY tableName, column_id
--ORDER BY SrcDB, SrcSchema, SRCtableName, SrcColumnID

--select distinct tableName, (md.[Current Database]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'))),columnName from [RMABIStaging].[dbo].[MetaData] md where tableName = 'cb_doc_header'

--select distinct tableName,columnName,* from #StagingTBLs where tableName = 'AccountsCBDocumentHeader'
--  select distinct tableName--,columnName
--    from #TransformationTBLs --where tableName LIKE '%Document%'
--order by tableName

--SELECT COUNT(*) FROM (
--SELECT DISTINCT tablename FROM #Base WHERE SrcDB = 'RMAProd'
--ORDER BY tablename
--) SRC

--   SELECT distinct 
--          ba.SrcDB
--         ,ba.SrcSchema
--         ,ba.[SRCtableName]
--         ,ba.SrcColumnName  --,REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')
--         ,ba.SrcColumnID
--         ,ba.SrcDataType
--		 ,ba.PrimaryKey
--         ,ba.[Database]
--         ,ba.[Schema Name]
--         ,ba.tableName
		 
--		 ,ba.columnName
		 
--		 ,ba.column_id
--         ,ba.DataType
--         ,ba.MaxLength
--		 --,NULLIF(ba.SrcDataType, ba.DataType) typediff
		 
--		 ,ba.[ProcSchemaName]
		 
--		 ,ba.objectName
		 
--		 ,ba.[ProcSchemaName1]

--		 --,ISNULL(tr.[Schema Name],'Transformation') as TrSchemaName
         
--		 ----,CASE
--			----WHEN ba.PrimaryKey = 1 THEN 'BK1' & REPLACE(ba.SrcColumnName,'ID','TransactionID')
			
--			----ELSE tr.tableName
--		 ---- END AS [tableName]

--   --      ,tr.tableName
--		 --,tr.columnName
		 
--		 ----,tr.columnName trcolumnName
         
--		 --,tr.column_id trcolumn_id
--   --      ,tr.DataType TrDataType
--   --      ,tr.MaxLength trMaxLength
--   --      ,tr.PrimaryKey trPrimaryKey
--   --      ,tr.objectName trobjectName
--   --      ,tr.[ProcSchemaName1] trProcSchemaName1
--   --      ,tr.objectName1 trobjectName1
--   --      ,tr.objectType1	trobjectType1
--		 --,ma.[Schema Name] as maSchemaName
--   --      ,ma.tableName matableName
--   --      ,ma.columnName macolumnName
--   --      ,ma.column_id macolumn_id
--   --      ,ma.DataType maDataType
--   --      ,ma.MaxLength maMaxLength
--   --      ,ma.PrimaryKey maPrimaryKey
--   --      ,ma.[Proc Schema Name] maProcSchemaName
--   --      ,ma.objectName maobjectName
--   --      ,ma.[ProcSchemaName1] maProcSchemaName1
--   --      ,ma.objectName1 maobjectName1
--   --      ,ma.objectType1	maobjectType1
--     FROM #Base ba 
--	      --FULL OUTER join #TransformationTBLs tr on ba.objectName1 = tr.objectName and CASE
--							--															WHEN ba.PrimaryKey = 1 THEN 'BK1' + REPLACE(ba.SrcColumnName,'ID','TransactionID')
--							--															WHEN ba.SrcColumnName = 'LastChangedBy' THEN 'SKUserID'
--							--															ELSE (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook'))
--							--														   END = tr.columnName
--	      --left join #Mart ma on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
--		-- SELECT tr.*
--		 --FROM #Mart ma
--		 --LEFT JOIN #TransformationTBLs tr on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
--		 -- LEFT JOIN #Base ba on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
	      
--		WHERE ba.[Schema Name] IS NOT NULL
--		--AND NULLIF(ba.SrcDataType, ba.DataType) IS NOT NULL

--  --  WHERE ((ba.SrcDB = 'RMAProd'
--	 -- and  ba.SrcSchema ='Compensation'
--		--and  ba.[SRCtableName] in ('ClaimEstimate'/*,'ClaimEstimateAudit'*/))
--		--OR tr.tableName = 'FactClaimEstimateTransaction')
-- ORDER BY ba.[SrcDB],ba.SrcSchema,ba.[SRCtableName], ba.SrcColumnID --ba.SrcColumnName

---- --SELECT distinct * into #Base1  FROM #Base ba

---- --  SELECT DB_NAME() AS [Current Database],* 
---- --    FROM #TransformationTBLs tr
---- --   WHERE tr.tableName = 'FactAbilityPensionPaymentWorkingTransaction'
---- --ORDER BY 5


--SELECT t.name tablename, s.name schemaname from Sys.Tables t
--JOIN sys.schemas s ON t.schema_id = s.schema_id
--WHERE t.schema_id = 5
--AND t.name NOT IN (
--SELECT tableName FROM
--(
----SELECT DISTINCT ba.SrcDB
----FROM (
--   SELECT distinct 
--          ba.SrcDB
--         ,ba.SrcSchema
--         ,ba.[SRCtableName]
--         ,ba.SrcColumnName  --,REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')
--         ,ba.SrcColumnID
--         ,ba.SrcDataType
--		 ,ba.PrimaryKey
--         ,ba.[Database]
--         ,ba.[Schema Name]
--         ,ba.tableName
--		 ,ba.columnName
--		 ,ba.column_id
--         ,ba.DataType
--         ,ba.MaxLength
--		 --,NULLIF(ba.SrcDataType, ba.DataType) typediff
		 
--		 ,ba.[ProcSchemaName]
		 
--		 ,ba.objectName		 

--     FROM #Base ba 
	      
--		WHERE ba.[Schema Name] IS NOT NULL
--		--AND NULLIF(ba.SrcDataType, ba.DataType) IS NOT NULL

--  --  WHERE ((ba.SrcDB = 'RMAProd'
--	 -- and  ba.SrcSchema ='Compensation'
--		--and  ba.[SRCtableName] in ('ClaimEstimate'/*,'ClaimEstimateAudit'*/))
--		--OR tr.tableName = 'FactClaimEstimateTransaction')
-- --ORDER BY ba.[SrcDB],ba.SrcSchema,ba.[SRCtableName], ba.SrcColumnID --ba.SrcColumnName
-- ) as ba)
-- ORDER BY t.name

-- SELECT Count(*) SourceTables, COUNT([Database]) StagingTables
-- FROM
-- (
--   SELECT distinct 
--          ba.SrcDB
--         ,ba.SrcSchema
--         ,ba.[SRCtableName]
--		 ,dw.[Database]
--		 ,dw.[Schema Name]
--		 ,dw.tableName
--     FROM #Base ba 
--	 LEFT JOIN #Base dw ON ba.SrcDB = dw.SrcDB
--							AND ba.SrcSchema = dw.SrcSchema
--							AND ba.[SRCtableName] = dw.[SRCtableName]
--							AND dw.[Schema Name] IS NOT NULL
--	) map      
--		--WHERE ba.[Schema Name] IS NOT NULL
--		--AND NULLIF(ba.SrcDataType, ba.DataType) IS NOT NULL

--  --  WHERE ((ba.SrcDB = 'RMAProd'
--	 -- and  ba.SrcSchema ='Compensation'
--		--and  ba.[SRCtableName] in ('ClaimEstimate'/*,'ClaimEstimateAudit'*/))
--		--OR tr.tableName = 'FactClaimEstimateTransaction')
-- --ORDER BY ba.[SrcDB],ba.SrcSchema,ba.[SRCtableName], ba.SrcColumnID --ba.SrcColumnName

---- --  SELECT DB_NAME() AS [Current Database],* 
---- --    FROM #Mart mt
---- --   WHERE mt.tableName = 'FactAbilityPensionPaymentWorkingTransaction'
---- --ORDER BY 2,4 



---- --select *
---- --  from #StagingTBLs


----SELECT COUNT(*) FROM [RMABIStaging].[dbo].[MetaData]
----SELECT COUNT(*) FROM #StagingTBLs
----SELECT top 10 * FROM #TransformationTBLs tr 
----SELECT COUNT(*) FROM #Mart ma               
----SELECT COUNT(*) FROM #Base ba 

--------17633
----SELECT distinct top 10 *, (md.[Schema Name]+REPLACE(md.[tableName],'_','')) FROM [RMABIStaging].[dbo].[MetaData] md WHERE (md.[Schema Name]+REPLACE(md.[tableName],'_','')) LIKE '%Ability%'
----SELECT distinct  *, (st.[Schema Name]+REPLACE(st.[tableName],'_','')) FROM #StagingTBLs st  WHERE (st.[Schema Name]+REPLACE(st.[tableName],'_','')) LIKE '%Ability%'


---- ma.[Schema Name] as maSchemaName
----,ma.tableName matableName
----,ma.columnName macolumnName
----,ma.column_id macolumn_id
----,ma.DataType maDataType
----,ma.MaxLength maMaxLength
----,ma.PrimaryKey maPrimaryKey
----,ma.[Proc Schema Name] maProcSchemaName
----,ma.objectName maobjectName
----,ma.[ProcSchemaName1] maProcSchemaName1
----,ma.objectName1 maobjectName1
----,ma.objectType1	maobjectType1



----SELECT *
----FROM #Base ba 
----	      --left join #TransformationTBLs tr on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
----	      --left join #Mart ma on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
----		-- SELECT tr.*
----		 --FROM #Mart ma
----		 --LEFT JOIN #TransformationTBLs tr on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
----		 -- LEFT JOIN #Base ba on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
	      
----    WHERE ba.SrcDB = 'RMAProd'
----	  and  ba.SrcSchema ='Compensation'
----		and  ba.[SRCtableName] in ('ClaimEstimate')




----SELECT *
----FROM #Base ba 
----	      --left join #TransformationTBLs tr on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
----	      --left join #Mart ma on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
----		-- SELECT tr.*
----		 --FROM #Mart ma
----		 --LEFT JOIN #TransformationTBLs tr on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
----		 -- LEFT JOIN #Base ba on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
	      
----    WHERE ba.SrcDB = 'RMAProd'
----	  and  ba.SrcSchema ='Compensation'
----		and  ba.[SRCtableName] in ('ClaimEstimate')


----SELECT	DISTINCT 
----			ba.SrcDB			AS	[Source DataBase],
----			ba.SrcSchema		AS	[Source Schema],
----			ba.[SRCtableName]	AS	[Source Table],
----			dw.[Database]		AS	[Destination DataBase],
----			dw.[Schema Name]	AS	[Destination Schema],
----			dw.tableName		AS	[Destination Table]
------INTO		#Temp
----FROM		#Base				AS	BA	 
----LEFT JOIN	#Base				AS	DW			
----ON			ba.SrcDB			=	dw.SrcDB
----AND			ba.SrcSchema		=	dw.SrcSchema
----AND			((ba.[SRCtableName]	=	dw.[SRCtableName]) OR (CONCAT(ba.SrcSchema, REPLACE(ba.SRCtableName, 'RMA', '')) = dw.tableName)) OR CONCAT(ba.SrcSchema, ba.tableName)	=	dw.tableName
----AND			dw.[Schema Name]		IS NOT NULL
----WHERE		ba.SrcDB			=	'RMAProd'
----AND	SUBSTRING(dw.tableName,1,3) NOT IN
----(
----	'CFG',
----	'CLC',
----	'BPM',
----	'BHF',
----	'API',
----	'CPM',
----	'MDM'	

----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CFG'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CLC'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'BPM'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'BHF'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'API'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CPM'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'MDM'


----AND LEFT(dw.tableName, 3) LIKE '%CFG%'
----AND dw.tableName	NOT LIKE '%CFG%'
----AND dw.tableName	NOT LIKE '%CLC%'
----AND dw.tableName	NOT LIKE '%BPM%'
----AND	dw.tableName	NOT	LIKE '%BHF%'
----AND	dw.tableName	NOT	LIKE '%API%'
----AND	dw.tableName	NOT	LIKE '%CPM%'
----AND	dw.tableName	NOT	LIKE '%MDM%'


----DROP TABLE #ProdTemp 


--SELECT	DISTINCT 
--			ba.SrcDB			AS	[Source DataBase],
--			ba.SrcSchema		AS	[Source Schema],
--			ba.[SRCtableName]	AS	[Source Table],
--			dw.[Database]		AS	[Destination DataBase],
--			dw.[Schema Name]	AS	[Destination Schema],
--			dw.tableName		AS	[Destination Table]
----INTO		#ProdTemp
--FROM		#Base				AS	BA	 
--LEFT JOIN	#Base				AS	DW			
--ON			ba.SrcDB			=	dw.SrcDB
--AND			ba.SrcSchema		=	dw.SrcSchema
--AND			CASE
----            WHEN	ba.SrcDB	=	'Accounts' AND ba.SrcSchema	=	'dbo'  AND ba.SRCtableName	like '%_doc_%'AND ba.SrcSchema	=	'dbo'
----			THEN	CONCAT(ba.SrcDB, REPLACE(REPLACE(ba.SRCtableName, '_', ''), 'doc', 'document'))
----			WHEN	ba.SrcDB	=	'Accounts' AND ba.SrcSchema	=	'dbo' AND ba.SRCtableName	LIKE '%_%'
----			THEN	CONCAT(ba.SrcDB, REPLACE(ba.SRCtableName, '_', '')) 
----			WHEN	ba.SrcDB	=	'Accounts' 
----			THEN	CONCAT(ba.SrcDB, ba.SRCtableName) 

------			select ba.SRCtableName,CONCAT(ba.SrcDB, REPLACE(REPLACE(ba.SRCtableName, '_', ''), 'doc', 'document')) from #Base ba where ba.SrcDB	=	'Accounts' AND ba.SrcSchema	=	'dbo'  AND ba.SRCtableName	like '%_doc_%'

------			Accountscbdocumentheader
------			AccountsCBDocumentHeader
------SELECT DISTINCT 	SRCtableName,tableName
------FROM	#Base
------WHERE	SrcDB	=	'Accounts'
-----------------------------------------------------------------------------------------------------------------------------
------IMAGING
-----------------------------------------------------------------------------------------------------------------------------
----			WHEN	BA.SrcDB	=	'Imaging' AND BA.SrcSchema	=	'RMA' AND dw.tableName	LIKE '%RMA%'
----			THEN	CONCAT(BA.SrcDB,ba.SrcSchema, ba.SRCtableName)
----			WHEN	ba.SrcDB	=	'Imaging'	AND ba.SrcSchema = 'Audit' AND ba.srcTableName LIKE '%RMA%'
----			THEN	CONCAT(ba.srcDB,ba.SrcSchema,REPLACE(ba.SRCtableName, '_', ''))
----			WHEN	Ba.SrcDB	=	'Imaging'	AND ba.SrcSchema = 'Audit'
----			THEN	CONCAT(BA.SrcDB,ba.SrcSchema, ba.SRCtableName)
----			WHEN	BA.SrcDB	=	'Imaging' AND BA.SrcSchema	=	'dbo'
----			THEN	CONCAT(BA.SrcDB,ba.SrcSchema, ba.SRCtableName)
----			WHEN	BA.SrcDB	=	'Imaging' AND BA.SrcSchema	=	'RMA'
----			THEN	CONCAT(BA.SrcDB, ba.SRCtableName)
----			--------WHEN	BA.SrcDB	=	'Imaging' AND BA.SrcSchema	=	'RMA' AND dw.tableName	=	CONCAT(ba.srcDB, ba.srctablename)
----			--------THEN	CONCAT(BA.SrcDB, ba.SRCtableName)
----			--------WHEN	ba.SrcDB	=	'RMAProd'	AND ba.SrcSchema	=	'Medical'
----			--------THEN	CONCAT(ba.SrcSchema,ba.Srctablename)
----			--------WHEN	ba.SrcDB	=	'Imaging'	AND ba.SrcSchema = 'Audit' AND ba.srcTableName LIKE '%RMA%'
----			--------THEN    CONCAT(ba.srcDB,ba.SrcSchema,REPLACE(ba.SRCtableName, '_', ''))
----			--------WHEN	BA.tableName IN('%RMARole%', '%RMAUserRole%') 
----			--------THEN	CONCAT(ba.SrcSchema, REPLACE(ba.SRCtableName, 'RMA', ''))
------------------------------------------------------------------------------------------------------------------------------
------RMAPROD
------------------------------------------------------------------------------------------------------------------------------
--			WHEN	LEFT(dw.tableName,11) != 'SecurityRMA' AND ba.SrcDB	=	'RMAProd' AND ba.SrcSchema	=	'Security'
--			THEN	CONCAT(ba.SrcSchema, REPLACE(ba.SRCtableName, 'RMA', ''))
--			WHEN	ba.[Schema Name]	=	'Security' AND LEFT(ba.tableName,3) = 'RMA' 
--			THEN	CONCAT	(ba.SrcSchema, ba.[SRCtableName])
--			WHEN	ba.[Schema Name]	=	'Common' AND LEFT(ba.tableName,3) = 'RMA' 
--			THEN	CONCAT	(ba.SrcSchema, ba.[SRCtableName])	
--			WHEN	ba.[Schema Name]	=	'Common' AND LEFT(ba.tableName,3) = 'RMA'
--			THEN	CONCAT(ba.SrcSchema, ba.[SRCtableName])	
--			WHEN	ba.SrcSchema =	'Medical' AND ba.SRCtableName	LIKE	'%ItemType%'	
--			THEN	ba.tableName
--			ELSE	CONCAT(ba.SrcSchema, ba.[SRCtableName])	
--			END		=	dw.tableName

--AND			dw.[Schema Name]		IS NOT NULL
--AND			(CONCAT(ba.SrcSchema, REPLACE(ba.SRCtableName, 'RMA', '')) = dw.tableName) OR CONCAT(ba.SrcSchema, ba.tableName) = dw.tableName
--WHERE	ba.SrcDB	=	'RMAProd' --ba.[Schema Name]	=	'Staging'
------AND ba.SrcSchema = 'Security'
------AND dw.tableName LIKE 'SecurityRMA%'
------OR			ba.SrcDB			=	'Imaging'
------OR			ba.SrcDB			=	'Accounts'
----SUBSTRING(dw.tableName,1,3) NOT IN
----(
----	'CFG',
----	'CLC',
----	'BPM',
----	'BHF',
----	'API',
----	'CPM',
----	'MDM'	
----)	


----SELECT	*
----FROM	#Temp


----DROP TABLE #Comp

----SELECT	DISTINCT T.name AS [Source TBL Name], B.tableName AS [Destination TBL Name],ssch.name AS	[Schema]
----INTO	#Comp
----FROM	sys.sql_dependencies d
----         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
----	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
----		  INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
----		 LEFT JOIN #Base AS B ON				t.name		=	B.tableName
----WHERE	ssch.name =	'Staging'
----AND		SUBSTRING(B.tableName,1,3) NOT IN
----(
----	'CFG',
----	'CLC',
----	'BPM',
----	'BHF',
----	'API',
----	'CPM',
----	'MDM'	
----)	
----ORDER	BY	B.tableName DESC

----SELECT	C.[Source TBL Name], T.[Destination Table]
----FROM	#Comp	AS	C
----LEFT	JOIN	#Temp	AS	T
----ON		C.[Source TBL Name]	=	T.[Destination Table]

----SELECT	DISTINCT SrcDB,tableName
----FROM	#Base
----WHERE	SrcDB	=	'Accounts'

--SELECT COUNT(*), COUNT(tableName) FROM
--(
--SELECT	DISTINCT 'RMAProd' as [SrcDatabase], sc.name SrcSchema, tb.name SrcTableName, dw.[Database], dw.tableSchema, dw.tableName
--FROM	RMAProd.sys.tables tb 
--JOIN	RMAProd.sys.schemas sc ON tb.schema_id = sc.schema_id
--LEFT JOIN	#Base				AS	DW			
--ON			'RMAProd'			=	dw.SrcDB
--AND			sc.name				=	dw.SrcSchema
--AND			tb.name				=	dw.SRCtableName
--) SRC


----SELECT	TOP 10 *
----FROM	#Temp
----WHERE	[Destination Table]LIKE '%Imaging%'

----WHERE	sys.schemas	LIKE	'%Staging%'	

----SELECT	DISTINCT ba.SrcDB,ba.SrcSchema,ba.SRCtableName,ba.tableName,CONCAT(BA.SrcDB,ba.SrcSchema, ba.SRCtableName) g
----FROM	#Base	ba
----WHERE	ba.tableName =	'ImagingRMAMedicalImage'   --ba.tableName	=	'ImagingRMAMedicalImage'--ba.SrcDB	=	'Imaging' AND ba.SrcSchema	=	'RMA'
----WHERE	LEFT(tableName,8) 

----SELECT * FROM #Base
----WHERE tableName LIKE 'SecurityRMA%'
			
----			((ba.[SRCtableName]	=	dw.[SRCtableName]) OR (CONCAT(ba.SrcSchema, REPLACE(ba.SRCtableName, 'RMA', '')) = dw.tableName)) OR (CONCAT(ba.SrcSchema, ba.tableName)	=	dw.tableName)OR (CONCAT(ba.SrcDB, ba.SRCtableName) = ba.tableName)
----AND			dw.[Schema Name]		IS NOT NULL
----WHERE		(ba.SrcDB			=	'RMAProd'
----OR			ba.SrcDB			=	'Imaging'
----OR			ba.SrcDB			=	'Accounts')

----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CFG'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CLC'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'BPM'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'BHF'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'API'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'CPM'
----OR SUBSTRING(dw.tableName, 1, 3) NOT LIKE 'MDM'


----AND LEFT(dw.tableName, 3) LIKE '%CFG%'
----AND dw.tableName	NOT LIKE '%CFG%'
----AND dw.tableName	NOT LIKE '%CLC%'
----AND dw.tableName	NOT LIKE '%BPM%'
----AND	dw.tableName	NOT	LIKE '%BHF%'
----AND	dw.tableName	NOT	LIKE '%API%'
----AND	dw.tableName	NOT	LIKE '%CPM%'
----AND	dw.tableName	NOT	LIKE '%MDM%'






----OR			ba.SrcDB			=	'MDS' 
----OR			ba.SrcDB			=	'RMABIStaging'
----ORDER BY	dw.[Database]

----SELECT * FROM #Base
----WHERE tableName = 'SecurityUserBranch'


----UPDATE #Temp

----SET		[Database]	=	'',
----		[Schema Name]	=	'',
----		tableName		=	''
----WHERE	[Database] IS NULL AND [Schema Name] IS NULL AND tableName  IS NULL

----SELECT	COUNT ([Database])
----FROM	#Temp
----WHERE	[Schema Name]	= 'Staging'

--SELECT	*
--FROM	#Temp

-----------------------------------------------------------------------------
---- Staging -> Transformation
-----------------------------------------------------------------------------


--SELECT name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 5 -- Staging
--AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
----AND name LIKE '%Type'
--ORDER BY name

---- 44 Exact matches (43 Dim, 1 Fact)
---- 43 Dim__Profile tables will never be mapped from Staging
---- 154 Dim tables to resolve
----SELECT S.name staging, LEN(S.name), T.name transformation, LEN(T.name) - 3

--DROP TABLE #TransformationDim

--SELECT name
--INTO #TransformationDim
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 6 -- Transformation
--AND name LIKE 'Dim%'
--AND name Like '%Profile'
--AND name NOT IN (SELECT * FROM #TransformationDim)


----TRUNCATE TABLE #TransformationDim
--INSERT INTO #TransformationDim
--SELECT transformation FROM (
---- 123 Matches
--SELECT S.name staging, T.name transformation
--FROM
--(
--SELECT T.name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 6 -- Transformation
--AND T.name NOT LIKE '%Profile'
----AND T.name NOT LIKE '%Transaction' -- has no effect
--) T
--JOIN
--(
--SELECT name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 5 -- Staging
--AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
--) S
----ON SUBSTRING(REPLACE(T.name,'Dim',''),1,13) = SUBSTRING(S.name,1,13)
--ON REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.name,'Dim',''),'Finance','Accounts'),'GeneralLedger','GL'),'Debtor','DR'),'Creditor','CR'),'CashBook','CB'),'Parameter','Param') = REPLACE(REPLACE(S.name,'Dbo',''),'CT','')
--OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.name,'Dim',''),'Finance','Accounts'),'GeneralLedger','GL'),'Debtor','DR'),'Creditor','CR'),'CashBook','CB') = REPLACE(S.name,'Dbo','')
--OR REPLACE(T.name,'Dim','') = REPLACE(REPLACE(S.name,'Compensation',''),'Medical','')
--OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'MedicalMedical','Medical')
--OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'PensionPension','Pension')
--OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'Auth','Authorisation')
--ORDER BY S.name
----) SRC
--WHERE transformation NOT IN (SELECT * FROM #TransformationDim)

--SELECT * FROM #TransformationDim ORDER BY transformation




---- 42 Exact matches
--SELECT S.name staging, T.name transformation
--FROM
--(
--SELECT T.name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 6 -- Transformation
--AND T.name NOT LIKE '%Profile'
--) T
--JOIN
--(
--SELECT name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 5 -- Staging
--AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
--) S
----ON SUBSTRING(REPLACE(T.name,'Dim',''),1,13) = SUBSTRING(S.name,1,13)
--ON REPLACE(REPLACE(T.name,'Transaction',''),'Fact','') = S.name
--ORDER BY S.name


------ 117 Dimension tables matched - do not use
----SELECT name
----FROM RMADW.sys.tables T (NOLOCK)
----WHERE schema_id = 6 -- Transformation
----AND SUBSTRING(REPLACE(name,'Dim',''),1,5) IN (
----	SELECT SUBSTRING(name,1,5)
----	FROM RMADW.sys.tables T (NOLOCK)
----	WHERE schema_id = 5 -- Staging
----	AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
----	--ORDER BY name
----) 
----ORDER BY name

---- 241 Dimension tables
---- 120 Fact tables
--SELECT name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 6 -- Transformation
--AND name LIKE 'Dim%'
----AND name Like '%Profile'
--AND name NOT IN (SELECT * FROM #TransformationDim)
--ORDER BY name


----SELECT * FROM [Staging].[ClientStatus]

----SELECT * FROM [Transformation].[DimClientStatus]

SELECT * FROM [Staging].[AccountsBCBankStatement]
