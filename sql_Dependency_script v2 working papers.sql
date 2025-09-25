USE RMADW;

WITH Dependencies AS
     (
       SELECT DISTINCT DB_NAME() referencing_database_name
             ,OBJECT_NAME (referencing_id) referencing_entity_name
             ,ISNULL(referenced_schema_name,'dbo') referenced_schema_name
             ,referenced_entity_name
             ,ao.type_desc referenced_entity_type
             ,ISNULL(referenced_database_name,DB_NAME()) referenced_database_name
         FROM sys.sql_expression_dependencies sed
              JOIN sys.all_objects ao
           ON sed.referenced_entity_name = ao.name 
where referenced_entity_name = 'DimPayee'
     ORDER BY OBJECT_NAME (referencing_id) 
     )
,
     AllObjects AS
     (
       SELECT DB_NAME() DBName, name, type_desc
         FROM sys.all_objects
        WHERE type_desc IN ( 'VIEW','SQL_TABLE_VALUED_FUNCTION','SQL_STORED_PROCEDURE','SQL_INLINE_TABLE_VALUED_FUNCTION','USER_TABLE','SQL_SCALAR_FUNCTION' )
     --ORDER BY 3,2
     )
,
    ColumnsNames AS
    (
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
		  WHERE tab.name    = 'DimPayee'
		--order by schema_name,
		--		table_name, 
		--		column_id
     )

   SELECT DISTINCT AO.DBName
         ,CN.[schema_name]
		 ,CN.table_name 
		 ,AO.type_desc
		 --,CN.column_name
		 --,CN.data_type
		 --,CN.max_length
		 --,CN.precision
		 ,D.*
     FROM Dependencies D 
          LEFT JOIN AllObjects AO   ON D.referenced_database_name = AO.DBName      AND D.referenced_entity_name = AO.name AND D.referenced_entity_type = AO.type_desc
		  LEFT JOIN ColumnsNames CN ON D.referenced_schema_name   = CN.schema_name AND D.referenced_entity_name = CN.table_name
    WHERE D.referenced_database_name = 'RMADW'
	  AND CN.[schema_name] = 'Mart'
      AND D.referenced_entity_name   = 'DimPayee'
      --AND D.referenced_entity_type IS NULL