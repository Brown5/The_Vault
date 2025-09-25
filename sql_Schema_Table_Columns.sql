  SELECT distinct ssch.[name] as [Schema Name]
        ,t.name AS tableName
		,c.name AS columnName
		,c.column_id
        ,ty.Name 'DataType'
        ,c.max_length 'MaxLength'
        ,c.is_nullable
        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
		--,o.name AS objectName
		--,o.type_desc AS objectType
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     INNER JOIN sys.objects o ON d.object_id = o.object_id
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
   --WHERE t.name  = 'DimAbilityPensionPaymentWorkingProfile'
   --WHERE ssch.[name] = 'Transformation'
   WHERE c.name  LIKE '%PreAuth%'---= 'PreAuthorisationNumber' --
ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id





--SELECT top 10 * FROM sys.sql_dependencies d
--SELECT top 10 * FROM sys.columns c    
--SELECT top 10 * FROM sys.tables t     
--SELECT top 10 * FROM sys.objects o    
--SELECT top 10 * FROM sys.schemas ssch 