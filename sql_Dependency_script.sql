  SELECT referencing_schema_name, 
         referencing_entity_name,
         referencing_id, 
		 referencing_class_desc, 
		 is_caller_dependent
    FROM sys.dm_sql_referencing_entities ('client.Company', 'OBJECT');
GO

--  SELECT * 
--    FROM sys.sql_expression_dependencies  
--   WHERE referenced_id = OBJECT_ID ('client.Company'); 
--GO  

  --SELECT * 
  --  FROM sys.sql_expression_dependencies 
  -- WHERE referenced_id = 1580897049

--  SELECT Coalesce(Object_Schema_Name(referencing_id) + '.', '')
--         + --likely schema name
--         Object_Name(referencing_id) + --definite entity name
--         Coalesce('.' + Col_Name(referencing_id, referencing_minor_id), '') AS referencing,
--         Coalesce(referenced_server_name + '.', '')
--         + --possible server name if cross-server
--         Coalesce(referenced_database_name + '.', '')
--         + --possible database name if cross-database
--         Coalesce(referenced_schema_name + '.', '')
--         + --likely schema name
--         Coalesce(referenced_entity_name, '')
--         + --very likely entity name
--         Coalesce('.' + Col_Name(referenced_id, referenced_minor_id), '') AS referenced
--    FROM sys.sql_expression_dependencies
--   WHERE referencing_id = Object_Id('client.Company')
--ORDER BY referenced;