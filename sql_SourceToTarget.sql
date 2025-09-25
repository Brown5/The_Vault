Use RMADW;

    drop table if exists #StagingTBLs

  SELECT distinct ssch.[name] as [Schema Name]
        ,t.name AS tableName
		,c.name AS columnName
		,c.column_id
        ,ty.Name 'DataType'
        ,c.max_length 'MaxLength'
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
		,max(sscho.[name]) as [ProcSchemaName]
		,max(o.name) AS objectName
		,max(sscho1.[name]) as [ProcSchemaName1]
		,max(o1.name) AS objectName1
		,max(o1.type_desc) AS objectType1
    INTO #StagingTBLs
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     LEFT JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (1,5,7,8)
	     LEFT JOIN sys.objects oo ON d.object_id = oo.object_id and o.schema_id in (1,5,7,8)
	     LEFT JOIN sys.objects o1 ON d.object_id = o1.object_id and o1.schema_id in (1,6,7,8)
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
		 LEFT JOIN sys.schemas sscho ON oo.schema_id = sscho.schema_id and o.schema_id in (5)
		 LEFT JOIN sys.schemas sscho1 ON o1.schema_id = sscho1.schema_id and o1.schema_id in (6)
         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
   WHERE ssch.[name] = 'Staging'
    ----AND t.name = 'CompensationClaimEstimate'
group by ssch.[name]
        ,t.name 
		,c.name 
		,c.column_id
        ,ty.Name 
        ,c.max_length 
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0)
ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id


drop table if exists #TransformationTBLs
  SELECT distinct ssch.[name] as [Schema Name]
        ,t.name AS tableName
		,c.name AS columnName
		,c.column_id
        ,ty.Name 'DataType'
        ,c.max_length 'MaxLength'
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
		,max(sscho.[name]) as [ProcSchemaName]
		,max(o.name) AS objectName
		,max(sscho1.[name]) as [ProcSchemaName1]
		,max(o1.name) AS objectName1
		,max(o1.type_desc) AS objectType1
    INTO #TransformationTBLs
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     LEFT JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (1,5,6,7,8)
	     LEFT JOIN sys.objects oo ON d.object_id = oo.object_id and o.schema_id in (1,5,6,7,8)
	     LEFT JOIN sys.objects o1 ON d.object_id = o1.object_id and o1.schema_id in (1,6,7,8)
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
		 LEFT JOIN sys.schemas sscho ON oo.schema_id = sscho.schema_id and o.schema_id in (5,6,7)
		 LEFT JOIN sys.schemas sscho1 ON o1.schema_id = sscho1.schema_id and o1.schema_id in (6)
         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
   WHERE ssch.[name] = 'Transformation'
----     AND t.name = 'FactClaimEstimateTransaction'
group by ssch.[name]
        ,t.name 
		,c.name 
		,c.column_id
        ,ty.Name 
        ,c.max_length 
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0)
ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id

drop table if exists #Mart
  SELECT distinct ssch.[name] as [Schema Name]
        ,t.name AS tableName
		,c.name AS columnName
		,c.column_id
        ,ty.Name 'DataType'
        ,c.max_length 'MaxLength'
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
		,max(sscho.[name]) as [Proc Schema Name]
		,max(o.name) AS objectName
		,max(sscho1.[name]) as [ProcSchemaName1]
		,max(o1.name) AS objectName1
		,max(o1.type_desc) AS objectType1
    INTO #Mart
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     LEFT JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (1,5,6,7)
	     LEFT JOIN sys.objects oo ON d.object_id = oo.object_id and o.schema_id in (1,5,6,7)
	     LEFT JOIN sys.objects o1 ON d.object_id = o1.object_id and o1.schema_id in (1,6,7)
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
		 LEFT JOIN sys.schemas sscho ON oo.schema_id = sscho.schema_id and o.schema_id in (5,6,7)
		 LEFT JOIN sys.schemas sscho1 ON o1.schema_id = sscho1.schema_id and o1.schema_id in (5,6,7)
         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
   WHERE ssch.[name] = 'Mart'
     ----AND t.name = 'FactClaimEstimateTransaction'
group by ssch.[name]
        ,t.name 
		,c.name 
		,c.column_id
        ,ty.Name 
        ,c.max_length 
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0)
ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id


drop table if exists #Base

   SELECT sg.SrcDB
         ,sg.SrcSchema
         ,sg.[SRCtableName]
         ,sg.SrcColumnName
         ,sg.SrcColumnID
         ,sg.SrcDataType
         ,sg.[Database]
         ,sg.[Schema Name]
         ,sg.tableName
		 ,sg.columnName
		 ,sg.column_id
         ,sg.DataType
         ,sg.MaxLength
		 ,sg.[ProcSchemaName]
		 ,sg.objectName
		 ,sg.[ProcSchemaName1]
		 ,sg.objectName1
		 ,sg.objectType1   
		 ,MAX(CONVERT(TINYINT,sg.PrimaryKey)) AS PrimaryKey
     INTO #Base
     FROM
	      (
   SELECT 
			--'1' AS Query,
		  md.[Current Database] SrcDB
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName] SrcColumnName
         ,md.[column_id] SrcColumnID
         ,md.[DataType] SrcDataType
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      join #StagingTBLs st on (md.[Current Database] +md.[Schema Name]+REPLACE(md.[tableName],'_','')) = st.tableName and md.columnName = st.columnName
    WHERE md.[Current Database] = 'Imaging'
	  AND md.[tableName] is not null
	  ----and (md.[Current Database] +md.[Schema Name]+REPLACE(md.[tableName],'_','')) = 'ImagingDboApprovalStatus'

	

  UNION ALL

   SELECT 
			--'1' AS Query,
		  md.[Current Database] SrcDB
         ,md.[Schema Name] SrcSchema
         ,md.[tableName] [SRCtableName]
         ,md.[columnName] SrcColumnName
         ,md.[column_id] SrcColumnID
         ,md.[DataType] SrcDataType
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
	-- SELECT md.*
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st on REPLACE(md.[tableName],'_','') = st.tableName and md.columnName = st.columnName
    WHERE st.tableName is not null
	 --   AND md.[Current Database] = 'RMAProd'
	 -- and  md.[Schema Name] ='Compensation'
		--and  md.[tableName] in ('ClaimEstimate')

  UNION ALL

  SELECT	--'2' AS Query,
		  md.[Current Database] SrcDB--, (md.[Schema Name]+REPLACE(md.[tableName],'_',''))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	       left join #StagingTBLs st on (md.[Schema Name]+REPLACE(md.[tableName],'_','')) = st.tableName and md.columnName = st.columnName
		   where md.[tableName] is not null
		   --    WHERE md.[Current Database] = 'RMAProd'
				 -- and  md.[Schema Name] ='Compensation'
					--and  md.[tableName] in ('ClaimEstimate')
		--AND md.[Current Database] = 'RMAProd'
	 -- AND  md.[Schema Name] ='Compensation'
		--AND  md.[tableName] in ('ClaimEstimate')

  UNION ALL

  SELECT	--'3' AS Query,
		  md.[Current Database] SrcDB--, (md.[Schema Name]+REPLACE(md.[tableName],'_',''))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st on (md.[Current Database] +REPLACE(md.[tableName],'_','')) = st.tableName and md.columnName = st.columnName
    where st.tableName is not null 
	--AND md.[Current Database] = 'RMAProd'
	--  and  md.[Schema Name] ='Compensation'
	--	and  md.[tableName] in ('ClaimEstimate')
 

  UNION ALL
-----17633
   SELECT md.[Current Database] SrcDB--, (md.[Current Database]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	       join #StagingTBLs st on md.columnName = st.columnName and (md.[Current Database]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))= st.tableName
    where md.[Current Database] = 'Accounts' 
	  --and md.tableName = 'cb_doc_header' 
  
  UNION ALL

   SELECT md.[Current Database] SrcDB--, (md.[Current Database]+md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      join #StagingTBLs st on md.columnName = st.columnName and (md.[Current Database]+md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))= st.tableName
    where md.[Current Database] = 'RMABIStaging' 

  UNION ALL

   SELECT md.[Current Database] SrcDB
   --      , (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
		 --, (md.[Schema Name]+(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'),'claims','claim')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st 
	   on (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'))) =  RTRIM(LTRIM(st.tableName)) 
	  and md.columnName = st.columnName  
    where md.[Current Database] = 'MDS'

    UNION ALL

    SELECT md.[Current Database] SrcDB
   --      , (md.[Schema Name]+(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document')))
		 --, (md.[Schema Name]+(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'),'claims','claim')))
         ,md.[Schema Name]
         ,md.[tableName] [SRCtableName]
         ,md.[columnName]
         ,md.[column_id]
         ,md.[DataType]
         ,DB_NAME() AS [Database]
         ,st.[Schema Name]
         ,st.tableName
		 ,st.columnName
		 ,st.column_id
         ,st.DataType
         ,st.MaxLength
		 ,st.[ProcSchemaName]
		 ,st.objectName
		 ,st.[ProcSchemaName1]
		 ,st.objectName1
		 ,st.objectType1
		 ,md.PrimaryKey
     FROM [RMABIStaging].[dbo].[MetaData] md
	      left join #StagingTBLs st 
	   on (md.[Schema Name]+(REPLACE(REPLACE(REPLACE(md.[tableName],'_',''),'doc','Document'),'claims','claim'))) =  RTRIM(LTRIM(st.tableName))
	  and md.columnName = st.columnName  
    where md.[Current Database] = 'MDS'

	      ) sg
group by  sg.SrcDB
         ,sg.SrcSchema
         ,sg.[SRCtableName]
         ,sg.SrcColumnName
         ,sg.SrcColumnID
         ,sg.SrcDataType
         ,sg.[Database]
         ,sg.[Schema Name]
         ,sg.tableName
		 ,sg.columnName
		 ,sg.column_id
         ,sg.DataType
         ,sg.MaxLength
		 ,sg.[ProcSchemaName]
		 ,sg.objectName
		 ,sg.[ProcSchemaName1]
		 ,sg.objectName1
		 ,sg.objectType1   





drop table if exists RMABIStaging.dbo.Src2Target
   SELECT distinct 
          ba.SrcDB
         ,ba.SrcSchema
         ,ba.[SRCtableName]
         ,ba.SrcColumnName  --,REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')
         ,ba.SrcColumnID
         ,ba.SrcDataType
		 ,ba.PrimaryKey
         ,ba.[Database]
         ,ba.[Schema Name]
         ,ba.tableName		 
		 ,ba.columnName 
	     ,ba.column_id
         ,ba.DataType
         ,ba.MaxLength
		 ,ba.[ProcSchemaName]
		 ,ba.objectName
		 ,ba.[ProcSchemaName1]
		 ,ISNULL(tr.[Schema Name],'Transformation') as TrSchemaName
		 --,CASE
			--WHEN ba.PrimaryKey = 1 THEN 'BK1' & REPLACE(ba.SrcColumnName,'ID','TransactionID')
			--ELSE tr.tableName
		 -- END AS [tableName]
         ,tr.tableName trtableName
		 ,tr.columnName trcolumnName
		 --,tr.columnName trcolumnName
		 ,tr.column_id trcolumn_id
         ,tr.DataType TrDataType
         ,tr.MaxLength trMaxLength
         ,tr.PrimaryKey trPrimaryKey
         ,tr.objectName trobjectName
         ,tr.[ProcSchemaName1] trProcSchemaName1
         ,tr.objectName1 trobjectName1
         ,tr.objectType1	trobjectType1
		 ,ma.[Schema Name] as maSchemaName
         ,ma.tableName matableName
         ,ma.columnName macolumnName
         ,ma.column_id macolumn_id
         ,ma.DataType maDataType
         ,ma.MaxLength maMaxLength
         ,ma.PrimaryKey maPrimaryKey
         ,ma.[Proc Schema Name] maProcSchemaName
         ,ma.objectName maobjectName
         ,ma.[ProcSchemaName1] maProcSchemaName1
         ,ma.objectName1 maobjectName1
         ,ma.objectType1	maobjectType1
   --,CASE WHEN ba.PrimaryKey = 1 THEN 'BK1' + REPLACE(ba.SrcColumnName,'ID','TransactionID')
			--																			    WHEN ba.SrcColumnName = 'LastChangedBy' THEN 'SKUserID'
			--																				WHEN ba.SrcColumnName LIKE '%ID' AND tr.tableName IS NULL THEN 'SK'+ba.SrcColumnName
			--																			    ELSE (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook'))
			--																		         END as test
     into RMABIStaging.dbo.Src2Target
     FROM #Base ba 
	      FULL OUTER join #TransformationTBLs tr on ba.objectName1 = tr.objectName and CASE WHEN ba.PrimaryKey = 1 THEN 'BK1' + REPLACE(ba.SrcColumnName,'ID','TransactionID')
																						    WHEN ba.SrcColumnName = 'LastChangedBy' THEN 'SKUserID'
																							WHEN ba.SrcColumnName LIKe '%ID' AND tr.tableName IS NULL THEN 'SK'+ba.SrcColumnName
																						    ELSE (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook'))
																					         END = tr.columnName
	      left join #Mart ma on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
		-- SELECT tr.*
		 --FROM #Mart ma
		 --LEFT JOIN #TransformationTBLs tr on tr.objectName1 = ma.objectName and ma.columnName = tr.columnName
		 -- LEFT JOIN #Base ba on ba.objectName1 = tr.objectName and (REPLACE(REPLACE(REPLACE(ba.SrcColumnName ,'_',''),'no','number'),'cb','cashbook')) = tr.columnName
	      
   -- WHERE ((ba.SrcDB = 'RMAProd'
	  --and ba.SrcSchema ='Compensation'
	  --and ba.[SRCtableName] in ('ClaimEstimate'/*,'ClaimEstimateAudit'*/))
	  -- OR tr.tableName = 'FactClaimEstimateTransaction')
	  where ba.[SRCtableName] is not null
	  --where ba.SrcSchema  = 'Imaging'
 ORDER BY ba.[SRCtableName], ba.SrcColumnName



 


