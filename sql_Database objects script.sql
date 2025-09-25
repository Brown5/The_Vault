----exec sp_depends 'client.Employee'
----SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo')

  SELECT s.NAME+'.'+t.NAME TableName,
         --s.NAME TableSchema,
         p.ROWS RowCounts
    FROM sys.tables t 
	     INNER JOIN sys.schemas s    ON t.schema_id = s.schema_id
         INNER JOIN sys.indexes i    ON t.OBJECT_ID = i.OBJECT_ID
         INNER JOIN sys.partitions p ON i.OBJECT_ID = p.OBJECT_ID AND i.index_id = p.index_id
   WHERE s.NAME = 'Client' 
     AND p.ROWS > 3492
	 --AND t.NAME NOT LIKE '%Audit%'
GROUP BY t.NAME, 
         s.NAME,
		 p.ROWS
ORDER BY --p.ROWS
         s.NAME, 
         t.NAME


