

  SELECT ssch.[name] as [Schema Name],t.name AS tableName, c.name AS columnName, o.name AS objectName, o.type_desc AS objectType
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     INNER JOIN sys.objects o ON d.object_id = o.object_id
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
   WHERE c.name  = 'AuthorisedTotalAmount'
ORDER BY t.name, c.name


;WITH usedColumns AS (
SELECT t.name AS tableName, c.name AS columnName, o.name AS objectName, o.type_desc AS objectType, c.object_id, c.column_id
  FROM sys.sql_dependencies d
    INNER JOIN sys.columns c
	  ON d.referenced_major_id = c.object_id
	  AND d.referenced_minor_id = c.column_id
	INNER JOIN sys.tables t
	  ON c.object_id = t.object_id
	INNER JOIN sys.objects o
	  ON d.object_id = o.object_id
 --ORDER BY t.name, c.name
)

SELECT DISTINCT t.name AS tableName, c.name AS columnName
  FROM sys.columns c
    INNER JOIN sys.tables t
	  ON c.object_id = t.object_id
    LEFT OUTER JOIN usedColumns uc
	  ON c.object_id = uc.object_id
	  AND c.column_id = uc.column_id
 WHERE uc.object_id IS NULL


 USE RMADW;
--USE RMAProd;

  SELECT case when ssch.[name] = 'Staging' then 1
		      when ssch.[name] = 'Transformation' then 2
		      when ssch.[name] = 'Mart' then 3
		      when ssch.[name] = 'Derived' then 4
		      when ssch.[name] = 'Report' then 5
		      else 10 end as SchemaOrder
       ,ssch.[name] as [Schema Name]
       ,sprc.[name] as [Stored Procedure Name]
       ,ssch.[name] + '.' + sprc.[name] as [Full Name]
       ,OBJECT_DEFINITION(OBJECT_ID) AS [Object Definition]
       -- select sprc.*
   FROM sys.procedures sprc 
        INNER JOIN sys.schemas ssch ON sprc.schema_id = ssch.schema_id
  WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%Compensation%MedicalInvoice%'
    --AND OBJECT_DEFINITION(OBJECT_ID) LIKE '%Transaction%'
    --and ssch.[name] = 'Staging'
    --order by sprc.create_date desc
ORDER BY 1, 4


  SELECT ssch.[name] as [Schema Name],t.name AS tableName, c.name AS columnName, o.name AS objectName, o.type_desc AS objectType
    FROM sys.sql_dependencies d
         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
	     INNER JOIN sys.objects o ON d.object_id = o.object_id
		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
   WHERE c.name  = 'AuthorisedTotalAmount'
ORDER BY t.name, c.name

select *   FROM sys.objects sprc where object_id =1652916960


select *   FROM sys.sql_dependencies  sprc 
select *   FROM sys.columns  c  WHERE c.name  = 'AuthorisedTotalAmount' 

select * from  INFORMATION_SCHEMA.VIEW_COLUMN_USAGE 
    where  column_name = 'AuthorisedTotalAmount' 

	SELECT *
FROM sys.tables
WHERE tables.object_id IN (SELECT
	OBJECT_ID
FROM sys.columns
WHERE columns.name LIKE '%AuthorisedTotalAmount%') -- use your column name

SELECT referencing_schema_name, referencing_entity_name, referencing_id, referencing_class_desc, is_caller_dependent  
FROM sys.dm_sql_referencing_entities ('prcFactMedicalInvoiceTransaction', 'OBJECT');   
GO  


 SELECT TABLE_SCHEMA,
        TABLE_NAME,
        'EXEC sp_depends @objname = N''' + TABLE_SCHEMA + '.' + TABLE_NAME + '''' AS Command
   FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' 
    AND TABLE_SCHEMA = 'Staging' 
	AND TABLE_NAME = 'CompensationMedicalInvoice'


	EXEC sp_depends @objname = N'Staging.CompensationMedicalInvoice'


	 SELECT referencing_schema_name, referencing_entity_name,
 referencing_id, referencing_class_desc, is_caller_dependent
 FROM sys.dm_sql_referencing_entities ('Staging.ClientPaymentFrequencyType', 'OBJECT');
 GO


   select schema_name(tab.schema_id) as schema_name,
          tab.name as table_name, 
          col.column_id,
          col.name as column_name, 
          t.name as data_type,    
          col.max_length,
          col.precision
     from sys.tables as tab
          inner join sys.columns as col on tab.object_id = col.object_id
          left join sys.types as t on col.user_type_id = t.user_type_id
  WHERE tab.name  = 'DimPayee' 
 order by schema_name,
          table_name, 
          column_id

