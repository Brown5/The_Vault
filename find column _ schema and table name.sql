   SELECT SCHEMA_NAME(schema_id) AS schema_name
		 ,t.name AS table_name
         ,c.name AS column_name
     FROM sys.tables AS t
          INNER JOIN sys.columns c 
	   ON t.OBJECT_ID = c.OBJECT_ID
    WHERE c.name LIKE '%invoice%'
 ORDER BY schema_name
         ,table_name;